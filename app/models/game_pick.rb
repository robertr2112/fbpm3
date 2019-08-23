# == Schema Information
#
# Table name: game_picks
#
#  id              :integer          not null, primary key
#  pick_id         :integer
#  game_pick_id    :integer
#  chosenTeamIndex :integer
#  created_at      :datetime
#  updated_at      :datetime
#

class GamePick < ApplicationRecord

  belongs_to :pick
  
  validates :chosenTeamIndex, presence: true

end
