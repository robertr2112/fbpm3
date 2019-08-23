# == Schema Information
#
# Table name: seasons
#
#  id              :integer          not null, primary key
#  year            :string(255)
#  state           :integer
#  nfl_league      :boolean
#  number_of_weeks :integer
#  current_week    :integer
#  created_at      :datetime
#  updated_at      :datetime
#

require 'rails_helper'

describe Season do
  
  let(:season) { FactoryBot.create(:season_with_weeks, num_weeks: 4) }
 
  subject { season }

  it { should respond_to(:year) }
  it { should respond_to(:state) }
  it { should respond_to(:nfl_league) }
  it { should respond_to(:number_of_weeks) }
  it { should respond_to(:current_week) }
  it { should respond_to(:weeks) }
  it { should respond_to(:setState) }
  it { should respond_to(:isPending?) }
  it { should respond_to(:isOpen?) }
  it { should respond_to(:isClosed?) }
  it { should respond_to(:canBeClosed?) }
  it { should respond_to(:getCurrentWeek) }
  it { should respond_to(:updatePools) }
  
  it "isPending? should be true when state is Pend" do
    expect(season.isPending?).to be true
  end
  
  it "isOpen? should be true when state is Open" do
    season.setState(Season::STATES[:Open])
    expect(season.isOpen?).to be true
  end
  
  it "isClosed? should be true when state is Closed" do
    season.setState(Season::STATES[:Closed])
    expect(season.isClosed?).to be true
  end
  
  it "getCurrentWeek should return the current_week for the season" do
    season.current_week = 3
    expect(season.getCurrentWeek).to eq season.weeks[2]
  end
  
  describe "setState" do
    it "should be able to set state to Open" do
      season.setState(Season::STATES[:Open])
      expect(season.state).to equal(Season::STATES[:Open])
    end
    it "should be able to set state to Closed" do
      season.setState(Season::STATES[:Closed])
      expect(season.state).to equal(Season::STATES[:Closed])
    end
    it "should be able to set state to Pend" do
      season.state = Season::STATES[:Closed]
      season.setState(Season::STATES[:Pend])
      expect(season.state).to equal(Season::STATES[:Pend])
    end
  end
  
  describe "canBeClosed?" do
    it "should be false until all weeks are final" do
      expect(season.canBeClosed?).to eq false
    end
    
    it "should be true when all weeks are final" do
      season.weeks.each do |week|
        week.setState(Week::STATES[:Final])
      end
      expect(season.canBeClosed?).to eq true
    end
    
    it "should be false when no weeks are created" do
      season2 = FactoryBot.create(:season)
      expect(season2.canBeClosed?).to eq false
    end
    
    it "should be false when the number of weeks < number_of_weeks" do
      season2 = FactoryBot.create(:season)
      season2.number_of_weeks = 2
      season2.weeks << FactoryBot.create(:week)
      expect(season2.canBeClosed?).to eq false
    end
  end
  
  describe "updatePools" do
    let(:season3) { FactoryBot.create(:season_with_weeks_and_games, num_weeks: 3, num_games: 1) }
    
    before {
      # add scores for all games and all weeks in the season, where all home teams win (for simplicity)
      # for each week, but leave current week as 1 and don't mark any weeks as final
      add_season_games_scores(season3)
      
      # create pool with 5 users and 1 entry per user
      @users = setup_pool_with_users_and_entries(season3, 5, 1)
      @pool = @users[0].pools.first
      @current_week = season3.current_week
    }
        
    it "should update the current_week by one" do
      season3.updatePools
      expect(season3.current_week).to eq (@current_week + 1)
    end
    
    it "should not update the week if current_week == season.number_of_weeks" do
      season3.current_week = season3.number_of_weeks
      season3.updatePools
      expect(season3.current_week).to eq season3.number_of_weeks
    end
    
    it "should call pool.updateEntries" do
      pool_update_survivor_users(season3, @pool, @users, 4, 0)
      expect(numberRemainingSurvivorEntries(@pool)).to eq 4
    end
      
    
    it "should not call pool.updateEntries when current_week < pool.starting_week" do
      @pool.starting_week = 2
      @pool.save
      pool_update_survivor_users(season3, @pool, @users, 4, 0)
      expect(numberRemainingSurvivorEntries(@pool)).to eq 5
    end
    
  end
  
end
