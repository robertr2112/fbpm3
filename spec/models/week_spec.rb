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

require 'rails_helper'

describe Week do
  
  let(:season) { FactoryBot.create(:season_with_weeks, num_weeks: 1) }
  
  before(:each) do
    @week = season.weeks.first
  end

  subject {@week}

  it { should respond_to(:state) }
  it { should respond_to(:season_id) }
  it { should respond_to(:week_number) }
  it { should respond_to(:games) }
  it { should respond_to(:setState) }
  it { should respond_to(:checkStateOpen) }
  it { should respond_to(:checkStatePend) }
  it { should respond_to(:checkStateClosed) }
  it { should respond_to(:checkStateFinal) }
  it { should respond_to(:open?) }
  it { should respond_to(:closed?) }
  it { should respond_to(:buildSelectTeams) }
  it { should respond_to(:getWinningTeams) }
  it { should respond_to(:gamesValid?) }
  it { should respond_to(:deleteSafe?) }

  it { should be_valid }

  it "should have the right associated season_id" do
    season_id = @week.season_id
    expect(season_id).to eq season.id
  end

  describe "validations" do
    describe "should reject an invalid state" do
      before { @week.state = 4}
      it { should_not be_valid }
    end
    
    describe "should reject an invalid week_number < 1" do
      before { @week.week_number = 0}
      it { should_not be_valid }
    end
    
    describe "should reject an invalid week_number > 17" do
      before { @week.week_number = 18}
      it { should_not be_valid }
    end
    
    describe "should reject an invalid week_number == nil" do
      before { @week.week_number = nil}
      it { should_not be_valid }
    end
  end
  
  describe "setState" do
    it "should be able to set state to Pend" do
      @week.state = Week::STATES[:Closed]
      @week.setState(Week::STATES[:Pend])
      expect(@week.state).to equal(Week::STATES[:Pend])
    end
    it "should be able to set state to Open" do
      @week.setState(Week::STATES[:Open])
      expect(@week.state).to equal(Week::STATES[:Open])
    end
    it "should be able to set state to Closed" do
      @week.setState(Week::STATES[:Closed])
      expect(@week.state).to equal(Week::STATES[:Closed])
    end
    it "should be able to set state to Final" do
      @week.setState(Week::STATES[:Final])
      expect(@week.state).to equal(Week::STATES[:Final])
    end
  end
  
  it "checkStatePend should be true when state is Pend" do
    expect(@week.checkStatePend).to be true
  end
  
  it "checkStateOpen should be true when state is Open" do
    @week.setState(Week::STATES[:Open])
    expect(@week.checkStateOpen).to be true
  end
  
  it "checkStateClosed should be true when state is Closed" do
    @week.setState(Week::STATES[:Closed])
    expect(@week.checkStateClosed).to be true
  end
  
  it "checkStateFinal should be true when state is Final" do
    @week.setState(Week::STATES[:Final])
    expect(@week.checkStateFinal).to be true
  end

  describe "buildSelectTeams" do
    before(:each) do
      @season2 = FactoryBot.create(:season_with_weeks_and_games, num_weeks: 1, num_games: 4)
      @week = @season2.weeks.first
    end
    
    it "should return the correct number of teams (number of games * 2" do
      expect(@week.buildSelectTeams.count).to eq (@week.games.count * 2)
    end
    
    # Checking that the 2nd game home team matches(random check)
    it "should return the correct teams" do
      teams = @week.buildSelectTeams
      # Teams are delevered as game1.awayTeam, game1.homeTeam, game2.awayTeam, 
      # game2.homeTeam, etc.
      expect(teams[3].id).to eq (@week.games[1].homeTeamIndex)
    end
  end
  
  describe "getWinningTeams" do
    before(:each) do
      @season2 = FactoryBot.create(:season_with_weeks_and_games, num_weeks: 1, num_games: 4)
      @week = @season2.weeks.first
      
      # just to keep it interesting set odd games to homeTeam wins and even to awayTeam wins
      n = 1
      @week.games.each do |game|
        if n % 2 then
          game.awayTeamScore = 21
          game.homeTeamScore = 7
        else
          game.awayTeamScore = 7
          game.homeTeamScore = 21
        end
        n += 1
      end
      
    end
    
    it "should return the correct number of teams (with no ties)" do
      expect(@week.getWinningTeams.count).to eq @week.games.count
    end
    
    it "should return the correct number of teams (with one tie)" do
      @week.games[0].homeTeamScore = 21
      expect(@week.getWinningTeams.count).to eq (@week.games.count + 1)
    end
    
    it "should return the correct number of teams (with two ties)" do
      @week.games[0].homeTeamScore = 21
      @week.games[2].homeTeamScore = 21
      expect(@week.getWinningTeams.count).to eq (@week.games.count + 2)
    end
    
    # checking first game winner (awayTeam) is there first
    it "should return the correct teams (with no ties)" do
      teams = @week.getWinningTeams
      expect(teams[0]).to eq (@week.games[0].awayTeamIndex)
    end
    
    # checking that the first tied team is there(first game homeTeam)
    it "should return the correct teams (with one tie)" do
      @week.games[0].homeTeamScore = 21
      teams = @week.getWinningTeams
      expect(teams[1]).to eq (@week.games[0].homeTeamIndex)
    end
    
    # checking that the second tied team is there (third game homeTeam)
    it "should return the correct teams (with two ties)" do
      @week.games[0].homeTeamScore = 21
      @week.games[2].homeTeamScore = 21
      teams = @week.getWinningTeams
      expect(teams[4]).to eq (@week.games[2].homeTeamIndex)
    end
    
  end
  describe "gamesValid?" do
    before(:each) do
      @season2 = FactoryBot.create(:season_with_weeks_and_games, num_weeks: 1, num_games: 4)
      @week = @season2.weeks.first
    end
    
    it "should be true when all team indexes are the same" do
      expect(@week.gamesValid?).to be true
    end
    
    # Set first game to have same home and away team index
    it "should be false when a game has the same home and away team index" do
      @week.games[0].homeTeamIndex = @week.games[0].awayTeamIndex
      expect(@week.gamesValid?).to be false
    end
    
    # Set third game to have home team == first game away team
    it "should be false when an away team index is repeated in multiple games" do
      @week.games[2].awayTeamIndex = @week.games[0].awayTeamIndex
      expect(@week.gamesValid?).to be false
    end
    
    # Set third game to have home team == first game home team
    it "should be false when a home team index is repeated in multiple games" do
      @week.games[2].awayTeamIndex = @week.games[0].homeTeamIndex
      expect(@week.gamesValid?).to be false
    end
    
  end
  
  describe "deleteSafe?" do
    before(:each) do
      @season2 = FactoryBot.create(:season_with_weeks_and_games, num_weeks: 1, num_games: 4)
    end
    
    it "should return false when state is Open" do
      @week.setState(Week::STATES[:Open])
      expect(@week.deleteSafe?(season)).to be false
    end
    
    it "should return false when state is Closed" do
      @week.setState(Week::STATES[:Closed])
      expect(@week.deleteSafe?(season)).to be false
    end
    
    it "should return false when state is Final" do
      @week.setState(Week::STATES[:Final])
      expect(@week.deleteSafe?(season)).to be false
    end
    
    it "should return false when the week is not the last week created in the season." do
      @week = @season2.weeks.first
      expect(@week.deleteSafe?(season)).to be false
    end
  end
  
end
