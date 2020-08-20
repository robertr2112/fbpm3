# == Schema Information
#
# Table name: weeks
#
#  id          :integer          not null, primary key
#  season_id   :integer
#  state       :integer
#  week_number :integer
#  created_at  :datetime
#  updated_at  :datetime
#
require 'open-uri'
require 'nokogiri'
require 'pp'

class Week < ApplicationRecord

  STATES = { Pend: 0, Open: 1, Closed: 2, Final: 3 }

  belongs_to :season
  has_many   :games, dependent: :delete_all

  accepts_nested_attributes_for :games

  #validates_associated :games
  validates :state, inclusion:   { in: 0..3 }
  validates :week_number, numericality: { only_integer: true, greater_than: 0,
                                          less_than_or_equal_to: 17}
  validate :gamesValid?

  def setState(state)
    self.state = state
    self.save
  end

  def checkStatePend
    self.state == Week::STATES[:Pend]
  end

  def checkStateOpen
    self.state == Week::STATES[:Open]
  end

  def checkStateClosed
    self.state == Week::STATES[:Closed]
  end

  def checkStateFinal
    self.state == Week::STATES[:Final]
  end

  def open?
    checkStateOpen
  end

  def closed?
    checkStateClosed
  end

  # Find the game for this week from the team index
  def find_game(chosenTeamIndex)
    self.games.each do |game|
      if game.homeTeamIndex == chosenTeamIndex ||
         game.awayTeamIndex == chosenTeamIndex
        return game
      end
    end
    return nil
  end

  # Generate NFL schedule for a specified week
  def create_nfl_week
    nfl_games = get_nfl_sched(self.week_number)
    nfl_games.each do |nfl_game|
      home_team_name  = '%'+nfl_game[:home_team]+'%'
      home_team       = Team.where('name LIKE ?', home_team_name).first
      away_team_name  = '%'+nfl_game[:away_team]+'%'
      away_team       = Team.where('name LIKE ?', away_team_name).first
      # Create the time string
      if nfl_game[:date] && nfl_game[:time]
        game_date_time = DateTime.parse(nfl_game[:date] + " ," + Season.getSeasonYear + " " + nfl_game[:time] + " EDT")
      else
        game_date_time = nil
      end
      game = Game.create(week_id: self.id, awayTeamIndex: away_team.id,
                         homeTeamIndex: home_team.id,
                         game_date: game_date_time)
      self.games << game

      self.save

    end
  end

  # Update the week with the nfl week final scores
  def add_scores_nfl_week

    # Get all of the games/scores from NFL.com
    nfl_games = get_nfl_scores(self.week_number)

    #cycle through each game
    nfl_games.each do |nfl_game|

      # Get the Team records for this game
      home_team_name  = '%'+nfl_game[:home_team]+'%'
      home_team = Team.where('name LIKE ?', home_team_name).first
      away_team_name  = '%'+nfl_game[:away_team]+'%'
      away_team = Team.where('name LIKE ?', away_team_name).first


      # Check to make sure this NFL game is final
      if nfl_game[:final] == "FINAL"

        # sift through all of the games for the week
        self.games.each do |game|

          # Find the matching game
          if ((game.awayTeamIndex == away_team.id) &&
              (game.homeTeamIndex == home_team.id))

            # Update the scores
            game.awayTeamScore = nfl_game[:away_score]
            game.homeTeamScore = nfl_game[:home_score]

            game.save

          end
        end #self.games.each
      end # if FINAL
    end # nfl_games.each

    self.save

  end

  def buildSelectTeams
    select_teams = Array.new
    self.games.each do |game|
      team = Team.find(game.awayTeamIndex)
      select_teams << team
      team = Team.find(game.homeTeamIndex)
      select_teams << team
    end
    return select_teams
  end

  def getWinningTeams
    winning_teams = Array.new
    games = self.games
    games.each do |game|
      spread = game.awayTeamScore-game.homeTeamScore
      if spread != 0
        if (spread > 0)
          winning_teams << game.awayTeamIndex
        else
          winning_teams << game.homeTeamIndex
        end
      else
        # in case of a tie add both teams to winning teams
          winning_teams << game.awayTeamIndex
          winning_teams << game.homeTeamIndex
      end
    end
    return winning_teams
  end

  def gamesValid?
    games_to_check = self.games
    ret_code = true
    games_to_check.each do |current_game|
      # Check to make sure the current_game team isn't the same for both teams
      if current_game.homeTeamIndex == current_game.awayTeamIndex
        errors[:base] << "Week #{self.week_number} has errors:"
        current_game.errors[:homeTeamIndex] << "Home and Away Team can't be the same!"
        ret_code = false
      end
      games = games_to_check = self.games
      games.each do |game|
        # check that the current_game teams are not repeated in the other games
        if current_game != game
          if current_game.homeTeamIndex == game.homeTeamIndex || current_game.homeTeamIndex == game.awayTeamIndex
            errors[:base] << "Week #{self.week_number} has errors:"
            current_game.errors[:homeTeamIndex] << "Team names can't be repeated!"
            ret_code = false
          end
          if current_game.awayTeamIndex == game.awayTeamIndex || current_game.awayTeamIndex == game.homeTeamIndex
            errors[:base] << "Week #{self.week_number} has errors:"
            current_game.errors[:awayTeamIndex] << "Team names can't be repeated!"
            ret_code = false
          end
        end
      end
    end
    return ret_code
  end

  # !!!! Should this be moved to season model ??
  def deleteSafe?(season)
    if  self.checkStatePend  && (season.weeks.order(:week_number).last == self)
      return true
    else
      return false
    end
  end

#  private

  # Parse the schedule for specified week from nfl.com. Returns
  # an array of game information(:date, :time, :away_team, :home_team)
  def self.get_nfl_sched(weekNum)

    # Open the schedule home page
    url_path = "http://www.nfl.com/schedules/" + Season.getSeasonYear + "/REG" + weekNum.to_s
    doc = Nokogiri::HTML(open(url_path))

    # Get games information
    games = Array.new

    # Find all start dates
    start_dates_list = doc.search("//comment()[contains(.,'formattedDate')]")
    start_dates = Array.new
    start_dates_list.each do |strt_date|
      start_dates << strt_date.text.sub( /^( formattedDate:)\s+/, '').strip
    end

    # Find all start times
    start_times_list = doc.search("//comment()[contains(.,'formattedTime')]")
    start_times = Array.new
    start_times_list.each do |strt_time|
      start_times << strt_time.text.sub( /^( formattedTime:)\s+/, '').strip
    end

    # Get home teams (gets duplicates and the first game is repeated twice)
    away_team_names = doc.css('span.team-name.away')
    home_team_names = doc.css('span.team-name.home')

    # strip off the everything but the team ID
    away_teams = Array.new
    away_team_names.count.times do |n|
      away_teams << away_team_names[n].text

    end

    home_teams = Array.new
    home_team_names.count.times do |n|
      home_teams << home_team_names[n].text
    end

    # Remove duplicate game from list (quirk of NFL.com)
    # NOTE: Some years the first game is listed twice and other
    #       years it isn't, so added a check to see if the first two games are the same.
    #       If they are then adjust the arrays to remove the first game.
    if (away_teams[0] == away_teams[1]) &&
       (home_teams[0] == home_teams[1])

      start_dates.shift
      start_times.shift
      away_teams.shift
      home_teams.shift
    end

    away_teams.count.times do |gameNum|
      # Add the information to the games array
      games[gameNum] = {:date => start_dates[gameNum], :time => start_times[gameNum],
                   :away_team => away_teams[gameNum], :home_team => home_teams[gameNum]}
    end

    return games

  end

  # Get the final scores for an NFL week
  def get_nfl_scores(weekNum)

    # Open the schedule home page
    url_path = "http://www.nfl.com/schedules/" + Season.getSeasonYear + "/REG" + weekNum.to_s
    doc = Nokogiri::HTML(open(url_path))

    # Get games information
    games = Array.new

    gameNum = 0
    events = doc.css("li.schedules-list-matchup").map do |eventnode|
      away_team  = eventnode.at_css("span.team-name.away").text.strip
      home_team  = eventnode.at_css("span.team-name.home").text.strip
      game_final = eventnode.at_css("span.time").text.strip
      if game_final == "FINAL"
        away_score = eventnode.at_css("span.team-score.away").text.strip.to_i
        home_score = eventnode.at_css("span.team-score.home").text.strip.to_i
      else
        game_final = nil
        away_score = nil
        home_score = nil
      end

      games[gameNum] = {:away_team => away_team, :away_score => away_score,
                        :home_team => home_team, :home_score => home_score,
                        :final => game_final}

      gameNum = gameNum + 1

    end

    return games

  end
end
