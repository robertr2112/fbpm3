# == Schema Information
#
# Table name: teams
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  nfl        :boolean
#  imagePath  :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Team < ApplicationRecord
end
