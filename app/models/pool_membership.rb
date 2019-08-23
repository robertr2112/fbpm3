# == Schema Information
#
# Table name: pool_memberships
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  pool_id    :integer
#  owner      :boolean          default(FALSE), not null
#  created_at :datetime
#  updated_at :datetime
#

class PoolMembership < ApplicationRecord

  belongs_to :user
  belongs_to :pool

end
