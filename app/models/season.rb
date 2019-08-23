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

class Season < ApplicationRecord
  
  before_create do
    self.year = Time.now.strftime("%Y")
    self.current_week = 1
    self.state = Season::STATES[:Pend]
  end
  
  STATES = { Pend: 0, Open: 1, Closed: 2 }
  
  has_many :pools, dependent: :delete_all
  has_many :weeks, dependent: :delete_all

  def self.getSeasonYear
    year = Time.now.strftime("%Y").to_i
    month = Time.now.strftime("%m").to_i
    if (month >= 1) && (month <= 3)
      year = year - 1
    end
    return year.to_s
  end

  def setState(new_state)
    self.update_attribute(:state, new_state)
  end

  def isPending?
    self.state == STATES[:Pend]
  end

  def isOpen?
    self.state == STATES[:Open]
  end

  def isClosed?
    self.state == STATES[:Closed]
  end
  
  def canBeClosed?
    if self.weeks.empty?
      return false
    end
    if self.weeks.count != self.number_of_weeks
      return false
    end
    self.weeks.order(:week_number).each do |week|
      if !week.checkStateFinal
        return false
      end
    end
    return true
  end

  #
  # Return a link to the current_week record
  #
  def getCurrentWeek
    self.weeks.find_by_week_number(self.current_week)
  end

  #
  # Have every pool update their entries. This is called after a week is marked 'final'
  #
  def updatePools
    self.pools.each do |pool|
      if self.getCurrentWeek.week_number >= pool.starting_week
        pool.updateEntries(self.getCurrentWeek)
      end
    end
    if self.current_week < self.number_of_weeks
      self.update_attribute(:current_week, self.current_week+1)
    end
  end

end
