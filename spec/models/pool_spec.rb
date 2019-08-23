# == Schema Information
#
# Table name: pools
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  season_id       :integer
#  poolType        :integer
#  starting_week   :integer          default(1)
#  allowMulti      :boolean          default(FALSE)
#  isPublic        :boolean          default(TRUE)
#  password_digest :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#  pool_done       :boolean          default(FALSE)
#

require 'rails_helper'

describe Pool do
  
  let(:user) { FactoryBot.create(:user) }
  let(:season) { FactoryBot.create(:season) }
  let(:season_with_weeks) { FactoryBot.create(:season_with_weeks) }

  before do
    @pool_attr = { :name => "Pool 1", :poolType => 2, 
                   :isPublic => true }
    @pool = user.pools.build(@pool_attr.merge(season_id: season.id,
                                   starting_week: 1)) 
  end
  
  subject { @pool }
  
  it { should be_valid }
  
  it { should respond_to(:name) }
  it { should respond_to(:season_id) }
  it { should respond_to(:poolType) }
  it { should respond_to(:starting_week) }
  it { should respond_to(:allowMulti) }
  it { should respond_to(:isPublic) }
  it { should respond_to(:password_digest) }
  it { should respond_to(:password) }
  it { should respond_to(:users) }
  it { should respond_to(:pool_memberships) }
  it { should respond_to(:isMember?) }
  it { should respond_to(:isOwner?) }
  it { should respond_to(:setOwner) }
  it { should respond_to(:getOwner) }
  it { should respond_to(:isOpen?) }
  it { should respond_to(:addUser) }
  it { should respond_to(:removeUser) }
  it { should respond_to(:remove_memberships) }
  it { should respond_to(:typeSUP?) }
  it { should respond_to(:typePickEm?) }
  it { should respond_to(:typePickEmSpread?) }
  it { should respond_to(:typeSurvivor?) }
  it { should respond_to(:getEntryName) }
  it { should respond_to(:updateEntries) }
  it { should respond_to(:removeEntries) }
  it { should respond_to(:haveSurvivorWinner?) }
  it { should respond_to(:getSurvivorWinner) }
  it { should respond_to(:getCurrentWeek) }

 
  it "should have the right associated user" do
    user.save
    @user_id = @pool.users.last.id
    expect(@user_id).to eq user.id
  end

  it "should be associated with the correct season" do
    expect(@pool.season_id).to eq season.id
  end
  
  it "should show user as a member of the pool" do
    user.save
    @pool_membership = @pool.isMember?(user)
    expect(@pool_membership.user_id).to eq user.id
  end
  
  it "should allow a user to update the pool" do
    @pool.update_attributes(name: "new name")
    @pool.save
  end
   
  it "when pool name is already taken" do
    @pool.save
    pool_with_duplicate_name = user.pools.build(@pool_attr)
    expect(pool_with_duplicate_name).to_not be_valid
  end

  describe "when name is not present" do
    before { @pool.name =  " " }
    it { should_not be_valid }
  end

  describe "when name is too long" do
    before { @pool.name =  "a" * 31 }
    it { should_not be_valid }
  end

  describe "when poolType is invalid" do
    before { @pool.poolType = 4 }
    it { should_not be_valid }
  end

  describe "when isPublic is invalid" do
    before { @pool.isPublic = nil }
    it { should_not be_valid }
  end
   
  describe "ownership" do
    before do
      user.save
      @pool.setOwner(user,true)
    end
  
    it "should allow to set user as owner" do
      expect(@pool.isOwner?(user)).to eq true
    end
     
    it "should allow to set unset user as owner" do
      @pool.setOwner(user,false)
      expect(@pool.isOwner?(user)).to eq false
    end
     
    it "should show user as owner" do
      @pool_membership = @pool.isMember?(user)
      expect(@pool_membership.owner).to eq true
    end
     
    it "should get owner" do
      @user_id = @pool.getOwner
      expect(@user_id).to eq user
    end
  end
   
  describe "membership" do
    let(:user1) { FactoryBot.create(:user) }
    before {
      user.save
      @pool.addUser(user1)
    }
     
    it "should allow adding another user" do
      @pool_membership = @pool.isMember?(user1)
      expect(@pool_membership.user_id).to eq user1.id
    end

    it "should have a users count of 2 after adding a 2nd user" do
      expect(@pool.users.count).to eq 2
    end
     
    it "should allow removing a user" do
      @pool.removeUser(user1)
      @pool_membership = @pool.isMember?(user1)
      expect(@pool_membership).to eq nil
    end
    
    it "should test remove_memberships" do
      expect do
        @pool.remove_memberships
      end.to change(@pool.users, :count).by(-2)
    end
  end
  
  describe "entries" do
    let(:user1) { FactoryBot.create(:user) }
    before {
      @pool.addUser(user1)
    }
     
    it "should verify getEntryName == user.<user_name> for first entry" do
      entry = Entry.where(user_id: user1.id, pool_id: @pool.id).first	
      expect(entry.name).to eq user1.user_name
    end

    it "should allow a new entry" do
      expect do
        @pool.entries.create(name: @pool.getEntryName(user1), user_id: user1.id,
                             survivorStatusIn: true, supTotalPoints: 0)
      end.to change(@pool.entries, :count).by(1)
    end
    it "should verify getEntryName == user.<user_name>_1 for second entry" do
      entry_name = @pool.getEntryName(user1)
      expect(entry_name).to eq "#{user1.user_name}_1"
    end

    it "should allow user to change entry name" do
      entry = Entry.where(user_id: user1.id, pool_id: @pool.id).first	
      new_name = "test name 1"
      entry.update_attributes(name: new_name)
      expect(entry.name).to eq new_name
    end

    it "should allow removal of an entry" do
      new_entry = @pool.entries.create(name: @pool.getEntryName(user1), user_id: user1.id,
                           survivorStatusIn: true, supTotalPoints: 0)
      expect do
        new_entry.destroy
      end.to change(@pool.entries, :count).by(-1)
    end
  end

  #
  # Survivor pool tests
  #
  describe "of type survivor" do
    let(:season) { FactoryBot.create(:season_with_weeks_and_games, num_weeks: 3, num_games: 1) }
    before {
      # add scores for all games and all weeks in the season, where all home teams win (for simplicity)
      # for each week, but leave current week as 1 and don't mark any weeks as final
      add_season_games_scores(season)
      
      # create pool with 5 users and 1 entry per user
      @users = setup_pool_with_users_and_entries(season, 5, 1)
      @pool = @users[0].pools.first
    }
        
    describe "running updateEntries" do
      #
      # First week cases
      #
      describe "after first week marked final" do
        #
        # picked wrong team cases
        #
        describe "shows x remaining entries where x = entries_left - entries_who_picked_wrong_team" do
          it "should show 4 remaining entries when entries_left = 5 and entries_who_picked_wrong_team = 1" do
            # has <n> users pick homeTeam in first game which is always a winner, remainder pick losing away
            # team
            pool_update_survivor_users(season, @pool, @users, 4, 0)
            expect(numberRemainingSurvivorEntries(@pool)).to eq 4
          end
          
          it "should show 3 remaining entries when entries_left = 5 and entries_who_picked_wrong_team = 2" do
            # has <n> users pick homeTeam in first game which is always a winner, remainder pick losing away
            # team
            pool_update_survivor_users(season, @pool, @users, 3, 0)
            expect(numberRemainingSurvivorEntries(@pool)).to eq 3
          end
          
          it "should show 2 remaining entries when entries_left = 5 and entries_who_picked_wrong_team = 3" do
            # has <n> users pick homeTeam in first game which is always a winner, remainder pick losing away
            # team
            pool_update_survivor_users(season, @pool, @users, 2, 0)
            expect(numberRemainingSurvivorEntries(@pool)).to eq 2
          end
          
          it "should show 1 remaining entries when entries_left = 5 and entries_who_picked_wrong_team = 4" do
            # has <n> users pick homeTeam in first game which is always a winner, remainder pick losing away
            # team
            pool_update_survivor_users(season, @pool, @users, 1, 0)
            expect(numberRemainingSurvivorEntries(@pool)).to eq 1
          end
          
          it "should show 5 remaining entries if all picked wrong team" do
            # has <n> users pick homeTeam in first game which is always a winner, remainder pick losing away
            # team
            pool_update_survivor_users(season, @pool, @users, 0, 0)
            expect(numberRemainingSurvivorEntries(@pool)).to eq 5
          end
        end # Picked wrong team
        
        #
        # Forgot to pick cases
        #
        describe "shows x remaining entries where x = entries_left - entries_who_forgot_to_pick" do
          it "should show 4 remaining entries when entries_left = 5 and entries_who_forgot_to_pick = 1" do
            # has <n> users pick homeTeam in first game which is always a winner, remainder forgot to  
            # pick
            pool_update_survivor_users(season, @pool, @users, 4, 1)
            expect(numberRemainingSurvivorEntries(@pool)).to eq 4
          end
          
          it "should show 3 remaining entries when entries_left = 5 and entries_who_forgot_to_pick = 2" do
            # has <n> users pick homeTeam in first game which is always a winner, remainder forgot to  
            # pick
            pool_update_survivor_users(season, @pool, @users, 3, 2)
            expect(numberRemainingSurvivorEntries(@pool)).to eq 3
          end
          
          it "should show 2 remaining entries when entries_left = 5 and entries_who_forgot_to_pick = 3" do
            # has <n> users pick homeTeam in first game which is always a winner, remainder forgot to  
            # pick
            pool_update_survivor_users(season, @pool, @users, 2, 3)
            expect(numberRemainingSurvivorEntries(@pool)).to eq 2
          end
          
          it "should show 1 remaining entries when entries_left = 5 and entries_who_forgot_to_pick = 4" do
            # has <n> users pick homeTeam in first game which is always a winner, remainder forgot to  
            # pick
            pool_update_survivor_users(season, @pool, @users, 1, 4)
            expect(numberRemainingSurvivorEntries(@pool)).to eq 1
          end 
          
          it "should show 5 remaining entries when entries_left = 5 and entries_who_forgot_to_pick = 5" do
            # has <n> users pick homeTeam in first game which is always a winner, remainder forgot to  
            # pick
            pool_update_survivor_users(season, @pool, @users, 0, 5)
            expect(numberRemainingSurvivorEntries(@pool)).to eq 5
          end 
        end # Forgot to pick
      end # after first week marked final
      
      #
      # Last week cases (updateEntries is called through season.updatePools, this allows the season to
      #                  update the current_week properly. This is done instead of rebuilding all the mock
      #                  data with different current weeks set in pool.) !!!! May change this later.
      #
      describe "after final week marked final" do
        #
        # Picked wrong team cases
        #
        describe "shows x remaining entries where x = 5 entries_left - entries_who_picked_wrong_team" do
          it "should show 4 remaining entries when entries_left = 5 and entries_who_picked_wrong_team = 1" do
            # has <n> users pick homeTeam in first game which is always a winner, remainder pick losing away
            # team
            
            # week 1
            pool_update_survivor_users(season, @pool, @users, 5, 0)
            
            # week 2
            pool_update_survivor_users(season, @pool, @users, 5, 0)
            
            # week 3 (final)
            pool_update_survivor_users(season, @pool, @users, 4, 0)
            expect(numberRemainingSurvivorEntries(@pool)).to eq 4
                   
          end
          it "should show 3 remaining entries when entries_left = 5 and entries_who_picked_wrong_team = 2" do
            # has <n> users pick homeTeam in first game which is always a winner, remainder pick losing away
            # team
            
            # week 1
            pool_update_survivor_users(season, @pool, @users, 5, 0)
            
            # week 2
            pool_update_survivor_users(season, @pool, @users, 5, 0)
            
            # week 3 (final)
            pool_update_survivor_users(season, @pool, @users, 3, 0)
            expect(numberRemainingSurvivorEntries(@pool)).to eq 3
          end
          
          it "should show 2 remaining entries when entries_left = 5 and entries_who_picked_wrong_team = 3" do
            # has <n> users pick homeTeam in first game which is always a winner, remainder pick losing away
            # team
            
            # week 1
            pool_update_survivor_users(season, @pool, @users, 5, 0)
            
            # week 2
            pool_update_survivor_users(season, @pool, @users, 5, 0)
            
            # week 3 (final)
            pool_update_survivor_users(season, @pool, @users, 2, 0)
            expect(numberRemainingSurvivorEntries(@pool)).to eq 2
          end
          
          it "should show 1 remaining entries when entries_left = 5 and entries_who_picked_wrong_team = 4" do
            # has <n> users pick homeTeam in first game which is always a winner, remainder pick losing away
            # team
            
            # week 1
            pool_update_survivor_users(season, @pool, @users, 5, 0)
            
            # week 2
            pool_update_survivor_users(season, @pool, @users, 5, 0)
            
            # week 3 (final)
            pool_update_survivor_users(season, @pool, @users, 1, 0)
            expect(numberRemainingSurvivorEntries(@pool)).to eq 1
          end
          
          it "should show 5 remaining entries if all picked wrong team" do
            # has <n> users pick homeTeam in first game which is always a winner, remainder pick losing away
            # team
            
            # week 1
            pool_update_survivor_users(season, @pool, @users, 5, 0)
            
            # week 2
            pool_update_survivor_users(season, @pool, @users, 5, 0)
            
            # week 3 (final)
            pool_update_survivor_users(season, @pool, @users, 0, 0)
            expect(numberRemainingSurvivorEntries(@pool)).to eq 5
          end
        end # Picked wrong team
        
        #
        # Forgot to pick cases (last week)
        #
        describe "shows x remaining entries where x = 5 entries_left - entries_who_forgot_to_pick" do
          it "should show 4 remaining entries when entries_left = 5 and entries_who_forgot_to_pick = 1" do
            # has <n> users pick homeTeam in first game which is always a winner, remainder forgot to  
            # pick
            
            # week 1
            pool_update_survivor_users(season, @pool, @users, 5, 0)
            
            # week 2
            pool_update_survivor_users(season, @pool, @users, 5, 0)
            
            # week 3 (final)
            pool_update_survivor_users(season, @pool, @users, 4, 1)
            expect(numberRemainingSurvivorEntries(@pool)).to eq 4
          end
          
          it "should show 3 remaining entries when entries_left = 5 and entries_who_forgot_to_pick = 2" do
            # has <n> users pick homeTeam in first game which is always a winner, remainder forgot to  
            # pick
            
            # week 1
            pool_update_survivor_users(season, @pool, @users, 5, 0)
            
            # week 2
            pool_update_survivor_users(season, @pool, @users, 5, 0)
            
            # week 3 (final)
            pool_update_survivor_users(season, @pool, @users, 3, 2)
            expect(numberRemainingSurvivorEntries(@pool)).to eq 3
          end
          
          it "should show 2 remaining entries when entries_left = 5 and entries_who_forgot_to_pick = 3" do
            # has <n> users pick homeTeam in first game which is always a winner, remainder forgot to  
            # pick
            
            # week 1
            pool_update_survivor_users(season, @pool, @users, 5, 0)
            
            # week 2
            pool_update_survivor_users(season, @pool, @users, 5, 0)
            
            # week 3 (final)
            pool_update_survivor_users(season, @pool, @users, 2, 3)
            expect(numberRemainingSurvivorEntries(@pool)).to eq 2
          end
          
          it "should show 1 remaining entries when entries_left = 5 and entries_who_forgot_to_pick = 4" do
            # has <n> users pick homeTeam in first game which is always a winner, remainder forgot to  
            # pick
            
            # week 1
            pool_update_survivor_users(season, @pool, @users, 5, 0)
            
            # week 2
            pool_update_survivor_users(season, @pool, @users, 5, 0)
            
            # week 3 (final)
            pool_update_survivor_users(season, @pool, @users, 1, 4)
            expect(numberRemainingSurvivorEntries(@pool)).to eq 1
          end 
          
          it "should show 5 remaining entries when entries_left = 5 and entries_who_forgot_to_pick = 5" do
            # has <n> users pick homeTeam in first game which is always a winner, remainder forgot to  
            # pick
            
            # week 1
            pool_update_survivor_users(season, @pool, @users, 5, 0)
            
            # week 2
            pool_update_survivor_users(season, @pool, @users, 5, 0)
            
            # week 3 (final)
            pool_update_survivor_users(season, @pool, @users, 0, 5)
            expect(numberRemainingSurvivorEntries(@pool)).to eq 5
          end 
        end # Forgot to pick
      end # Final week marked final
    end  # running season.updatePools
      
    describe "getSurvivorWinner" do
      describe "two weeks after got down to one remaining entry" do
        it "should show 1 remaining entry" do
          # Down to 1 winner
          pool_update_survivor_users(season, @pool, @users, 1, 0)
            
         # week 2
          pool_update_survivor_users(season, @pool, @users, 0, 0)
            
         # week 3
          pool_update_survivor_users(season, @pool, @users, 0, 0)
            
          winning_entries = @pool.getSurvivorWinner
          expect(winning_entries.count).to eq 1
            
        end
      end
      
      describe "in the first week of pool" do
        describe "when one user remains" do
          it "should show that user as winner" do
            
            winning_entry = @pool.entries.where(user_id: @users[0].id)[0]
            pool_update_survivor_users(season, @pool, @users, 1, 0)
            winning_entries = @pool.getSurvivorWinner
            expect(winning_entries.first.id).to eq winning_entry.id
          end
        end
        
        describe "when more than one user remains" do
          it "should show no winners" do
            
            pool_update_survivor_users(season, @pool, @users, 3, 0)
            winning_entries = @pool.getSurvivorWinner
            expect(winning_entries).to be false 
          end
        end
        
        describe "when all 5 entries are knocked out of pool" do
          it "should show 5 remaining entries from previous week as winners" do
            # All knocked out of pool
            pool_update_survivor_users(season, @pool, @users, 0, 0)
            winning_entries = @pool.getSurvivorWinner
            expect(winning_entries.count).to eq 5
          end
        end
      end
      
      describe "when it is the last week" do
        it "should show 4 remaining entries as winners when 1 is knocked out" do
          # week 1
          pool_update_survivor_users(season, @pool, @users, 5, 0)
            
          # week 2
          pool_update_survivor_users(season, @pool, @users, 5, 0)
            
          # week 3
          pool_update_survivor_users(season, @pool, @users, 4, 0)
          winning_entries = @pool.getSurvivorWinner
          expect(winning_entries.count).to eq 4

        end
        
        it "should show 3 remaining entries as winners when 3 are still in pool" do
          # Down to 3 entries
          pool_update_survivor_users(season, @pool, @users, 5, 0)
            
          # week 2
          pool_update_survivor_users(season, @pool, @users, 5, 0)
            
          # week 3
          pool_update_survivor_users(season, @pool, @users, 3, 0)
          winning_entries = @pool.getSurvivorWinner
          expect(winning_entries.count).to eq 3

        end
        
        it "should show 2 remaining entries as winners when 2 are still in pool" do
          # Down to 2 entries
          pool_update_survivor_users(season, @pool, @users, 5, 0)
            
          # week 2
          pool_update_survivor_users(season, @pool, @users, 5, 0)
            
          # week 3
          pool_update_survivor_users(season, @pool, @users, 2, 0)
          winning_entries = @pool.getSurvivorWinner
          expect(winning_entries.count).to eq 2

        end
        
        it "should show 1 remaining entries as winners when 1 are still in pool" do
          # Down to 1 entries
          pool_update_survivor_users(season, @pool, @users, 5, 0)
            
          # week 2
          pool_update_survivor_users(season, @pool, @users, 5, 0)
            
          # week 3
          pool_update_survivor_users(season, @pool, @users, 1, 0)
          winning_entries = @pool.getSurvivorWinner
          expect(winning_entries.count).to eq 1

        end
      end
      
    end # getSurvivorWinner
  end # of type Survivor
  
end
