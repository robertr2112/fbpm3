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

class Pool < ApplicationRecord

  POOL_TYPES = { PickEm: 0, PickEmSpread: 1, Survivor: 2, SUP: 3 }

  has_many   :users, through: :pool_memberships
  has_many   :pool_memberships, dependent: :destroy
  has_many   :entries, dependent: :delete_all
  belongs_to :season

  # Make sure protected fields aren't updated after a week has been created on the pool
  validate :checkUpdateFields, on: :update

  attr_accessor :password

  validates :name,     presence:   true,
                       length:      { :maximum => 30 },
                       uniqueness:  { :case_sensitive => false }
if nil
  validates :poolType, inclusion:   { in: 0..3 }
else
  validates :poolType, exclusion:   { in: [0,1,3,4] }
end
  validates :allowMulti, inclusion: { in: [true, false] }
  validates :isPublic, inclusion:   { in: [true, false] }

  #
  # The following routines check the poolType. There is both a Class and
  # an Instance version of each routine.
  #
  def self.typeSUP?(type)
    if type == POOL_TYPES[:SUP]
      return true
    end
    return false
  end
  
  def self.typePickEm?(type)
    if type == POOL_TYPES[:PickEm]
      return true
    end
    return false
  end
  
  def self.typePickEmSpread?(type)
    if type == POOL_TYPES[:PickEmSpread]
      return true
    end
    return false
  end
  
  def self.typeSurvivor?(type)
    if type == POOL_TYPES[:Survivor]
      return true
    end
    return false
  end
  
  def typeSUP?
    if self.poolType == POOL_TYPES[:SUP]
      return true
    end
    return false
  end
  
  def typePickEm?
    if self.poolType == POOL_TYPES[:PickEm]
      return true
    end
    return false
  end
  
  def typePickEmSpread?
    if self.poolType == POOL_TYPES[:PickEmSpread]
      return true
    end
    return false
  end
  
  def typeSurvivor?
    if self.poolType == POOL_TYPES[:Survivor]
      return true
    end
    return false
  end

  #
  # Used to determine if the listed user is a member in the pool
  #
  def isMember?(user)
    self.pool_memberships.find_by_user_id(user.id)
  end

  #
  # Used to determine if the listed user is the owner of the pool.
  #
  def isOwner?(user)
    pool_membership = self.pool_memberships.find_by_user_id(user.id)
    if pool_membership
      pool_membership.owner
    end
  end

  def getOwner
    pool_membership = self.pool_memberships.find_by_owner(true)
    User.find(pool_membership.user_id)
  end
  #
  # This is used to determine if users can join/leave the pool.  Once the pool is no longer open then
  # users cannot join or leave the pool.
  #
  def isOpen?
    season = Season.find(self.season_id)
    first_week = season.weeks.find_by_week_number(self.starting_week)
    if self.typeSurvivor?
      if first_week && (first_week.checkStateClosed || first_week.checkStateFinal)
        return false
      else
        return true
      end
    else
      return true
    end
  end

  #
  # Used to set/remove ownership of the pool from the listed user
  #
  def setOwner(user, flag)
    pool_membership = self.pool_memberships.find_by_user_id(user.id)
    if pool_membership
      pool_membership.owner = flag
      pool_membership.save
    end
  end

  #
  #  Adds the listed user to the pool
  #
  def addUser(user)
    # Add user to the pool and save 
    user.pools << self
    self.setOwner(user, false)
    user.save
    # Create an entry in the pool for this user
    entry_name = self.getEntryName(user)
    new_entry_params = { name: entry_name }
    self.entries.create(new_entry_params.merge(user_id: user.id))
  end

  #
  # Removes the listed user from the pool
  #
  def removeUser(user)
    self.removeEntries(user)
    pool_membership = self.pool_memberships.find_by_user_id(user.id)
    pool_membership.destroy
  end

  #
  # Removes all memberships from the pool
  #
  def remove_memberships
    users = self.users.each do |user|
      pool_membership = self.pool_memberships.find_by_user_id(user.id)
      pool_membership.destroy
    end
  end

  #
  # Used to get a default entry name for a user.  The default is <first name><Last name first Initial>
  # for the first entry and then adds _<entry number>
  #
  def getEntryName(user)
    entries = self.entries.where(user_id: user.id)
    user_nickname = user.user_name
    if entries && entries.count > 0
        user_nickname = user_nickname + "_#{entries.count}"
    end
    return user_nickname
  end

  #
  # This routine is used to update the survivor status and SUP total points for those pools
  # for each entry.  It is called after a week is marked final.
  def updateEntries(current_week)
    if self.typeSurvivor?
      if !self.pool_done
        
        # Update all entries survivorStatus
        updateSurvivor(current_week)
        # Check to see if their is a winner and mark pool done if there is a winner
        haveSurvivorWinner?
      end
    elsif self.typeSUP?
      updateSUP(current_week)
    elsif self.typePickEm?
      updatePickEm(current_week)
    elsif self.typePickEmSpread?
      updatePickEmSpread(current_week)
    end
  end

  #
  # Used to remove all entries for a user from the pool.  It is called when a user leaves
  # the pool
  def removeEntries(user)
    entries = Entry.where({ pool_id: self.id, user_id: user.id })
    entries.each do |entry|
      entry.recurse_delete
    end
  end

  #
  # Determine if their are winners to the pool. If there are then return the entry.id's
  # of the winner(s). Returns FALSE if there are no winners yet.
  #
  def haveSurvivorWinner?
    getSurvivorWinner
  end
  
  def getSurvivorWinner
    season = Season.find(self.season_id)
    current_week = self.getCurrentWeek
    entries = self.entries.where(survivorStatusIn: true)
    if self.pool_done
      return entries
    elsif entries.count == 0
      self.update_attribute(:pool_done, true)
      return determineSurvivorWinners
    elsif ((current_week.week_number == season.number_of_weeks) &&
        current_week.checkStateFinal)
      self.update_attribute(:pool_done, true)
      return entries
    elsif (entries.count == 1 &&
             ((current_week.week_number >= self.starting_week) &&
              current_week.checkStateFinal))
      self.update_attribute(:pool_done, true)
      return entries
    end
    
    return false
  end

  #
  # Used to get the current week.  It calls season.getCurrentWeek.
  def getCurrentWeek
    season = Season.find(self.season_id)
    season.getCurrentWeek
  end

  private

    def pool_valid?
      if self.poolType != Pool::POOL_TYPES[:Survivor]
        if self.poolType == Pool::POOL_TYPES[:PickEm]
          type = "PickEm"
        elsif self.poolType == Pool::POOL_TYPES[:PickEmSpread]
          type = "PickEmSpread"
        else
          type = "SUP"
        end
        return true
      end
      return false
    end

    def checkUpdateFields
      if !self.isOpen?
        if (self.changed & ["poolType", "allowMulti"]).any?
          self.errors[:poolType] << "You cannot change the Pool attributes after the first week has completed!"
        end
      end
    end

    #
    #  This finds winners if they all happened to get knocked out the same week.
    #
    def determineSurvivorWinners
      # Find all picks from season.week_number - 1 and self.id (not sure easiest way to do it.)
      season = Season.find(self.season_id)
      current_week = season.getCurrentWeek
      previous_week = Week.find_by_week_number(current_week.week_number - 1)
      if !previous_week
        # If it's the first week then return all entries
        winners = self.entries
      else
        # If it's not the first week then determine everyone who was left the previous
        # week and return those entries
        winners = Array.new
        while winners.count == 0
          self.entries.each do |entry|
            picks = entry.picks.where(week_number: previous_week.week_number)
            if !picks.empty?
              winners << entry
            end
          end
          week_number = previous_week.week_number - 1
          previous_week = Week.find_by_week_number(week_number)
        end
      end
      # Now that we have determined the survivor winners let's mark the
      # SurvivorStatusIn back to true so getSurvivorWinner can return
      # the correct winners without calling this routine again.
      if winners
        winners.each do |entry|
          entry.update_attribute(:survivorStatusIn, true)
          entry.save
        end
      end
      return winners
    end

    #
    # Updates the survivor status of each surviving entry in the pool
    #
    def updateSurvivor(current_week)
      
      knocked_out_entries = Array.new
      winning_teams = current_week.getWinningTeams
      
      # Go through all entries and find those who picked a losing team
      self.entries.each do |entry|
        if entry.survivorStatusIn
          found_team = false
          picks = entry.picks.where(week_number: current_week.week_number)
          if picks
            picks.each do |pick|
              pick.game_picks.each do |game_pick|
                winning_teams.each do |team|
                  if game_pick.chosenTeamIndex == team
                    found_team = true
                  end
                end
              end
            end
            # Add this entry to the knocked_out list
            if !found_team
              knocked_out_entries << entry
            end
          end
        end
      end
      
      #
      # if knocked out, update survivor status to false
      #
      if knocked_out_entries
        knocked_out_entries.each do |entry|
          entry.update_attribute(:survivorStatusIn, false)
          entry.save
        end
      end
      return true
    end

    def updateSUP(current_week)
    end

    def updatePickEm(current_week)
    end

    def updatePickEmSpread(current_week)
    end
end
