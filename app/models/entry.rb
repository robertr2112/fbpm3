# == Schema Information
#
# Table name: entries
#
#  id               :integer          not null, primary key
#  pool_id          :integer
#  user_id          :integer
#  name             :string(255)
#  survivorStatusIn :boolean          default(TRUE)
#  supTotalPoints   :integer          default(0)
#  created_at       :datetime
#  updated_at       :datetime
#

class Entry < ApplicationRecord
  belongs_to :pool
  belongs_to :user
  has_many   :picks, dependent: :delete_all

  def entryStatusGood?
    if self.survivorStatusIn 
      return true
    else
      return false
    end
  end
  
  def madePicks?(week)
    picks = self.picks.where(week_id: week.id)
    picks.each do |pick|
      if (pick.entry_id == self.id && pick.week_number == week.week_number)
        return true
      end
    end
    return false
  end

end
