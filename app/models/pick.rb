# == Schema Information
#
# Table name: picks
#
#  id          :integer          not null, primary key
#  week_id     :integer
#  entry_id    :integer
#  week_number :integer
#  totalScore  :integer          default(0)
#  created_at  :datetime
#  updated_at  :datetime
#

class Pick < ApplicationRecord

  belongs_to :entry
  has_many :game_picks, dependent: :delete_all

  accepts_nested_attributes_for :game_picks

  validate :pickValid?


  # Used before a pick can be modified. It checks to see if the currently picked 
  # team's game has started. If it has already started then the current pick cannot be modified.
  # This is done to prevent someone from picking a different team AFTER the picked team's game is
  # over.  This is necessary in leagues that don't lock the league but use game start times to 
  # determine when a user can make their pick.  
  #
  #  CALLED FROM: Picks_controller.c
  #
  def pickLocked?
    current_game_pick = self.game_picks.first
    week = Week.find(self.week_id)
      
    game = week.find_game(current_game_pick .chosenTeamIndex)
    if game.game_started?
        return true
    else
       return false
    end
  end
  
  # prevents user from repicking a team in a survivor pool
  #
  # CALLED FROM: ActiveRecord validate
  #
  def pickValid?
    
    # Verify this team hasn't already been picked in this pool
    current_game_pick = self.game_picks.first
    entry = Entry.find(self.entry_id)
    entry.picks.each do |pick|
      old_game_pick = pick.game_picks.first
      if (old_game_pick != current_game_pick &&
          old_game_pick.chosenTeamIndex == current_game_pick.chosenTeamIndex)
        errors[:base] << "You have already picked this team!  Please choose another team."
        current_game_pick.errors[:chosenTeamIndex] << "You have already picked this team!  Please choose another team."
        return false
      end
    end
    
    if current_game_pick
      week = Week.find(self.week_id)
      
      game = week.find_game(current_game_pick.chosenTeamIndex)
      if game.game_started?
        errors[:base] << 
                       "This game has started!  Please choose another team."
        current_game_pick.errors[:chosenTeamIndex] << 
                       "This game has started!  Please choose another team."
        return false
      end
    end
    
    return true
  end

  # Build list of available teams to choose for a survivor pool
  #
  # CALLED FROM: Edit & New views for Picks
  #
  def buildSelectTeams(week)
    # Get all available teams for the current week
    all_teams = week.buildSelectTeams

    # Now remove the teams that this user has already picked
    avail_teams = Array.new
    entry = Entry.find(self.entry_id)
    all_teams.each do |team|
      used_team = false
      entry.picks.each do |pick|
        game_pick = pick.game_picks.first
        if pick.week_id != week.id && game_pick
          if team.id == game_pick.chosenTeamIndex
            used_team = true
          end
        end
      end
      if !used_team
        avail_teams << team
      end
    end
    
    return avail_teams
      
  end
  
end
