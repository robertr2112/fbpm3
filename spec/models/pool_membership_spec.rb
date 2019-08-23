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

require 'rails_helper'

describe PoolMembership do
  
  let(:user1) { FactoryBot.create(:user) }
  let(:user2) { FactoryBot.create(:user) }
  let(:season) { FactoryBot.create(:season_with_weeks) }

  before do
    @pool_attr = { :name => "Pool 1", :poolType => 2, :isPublic => true, 
                   season_id: season.id, starting_week: 1 }
    @pool1 = user1.pools.create(@pool_attr)
    @pool_membership = user1.pool_memberships.find_by_pool_id(@pool1)
  end

  subject {@pool_membership}

  it { should respond_to(:pool_id) }
  it { should respond_to(:user_id) }
  it { should respond_to(:owner) }

  describe "when creating a new pool" do

    describe "should add an entry in pool_memberships" do
      it { should be_valid }
    end

    it "should have the correct pool_id" do
      expect(@pool_membership.pool_id).to eq @pool1.id
    end
  end

  # !!!! Need to update this later to support other added poolType(s)
  describe "joining a pool" do
    before do
      @pool2 = user1.pools.create(@pool_attr.merge(:name => "Pool 2",
                                                    :poolType => 2))
      user2.pools << @pool1
    end

    it "should not add a new pool entry" do
      expect do
        user2.pools << @pool2
      end.not_to change(Pool, :count)
    end

    it "should add an entry in pool_memberships" do
      expect do
        user2.pools << @pool2
      end.to change { user2.pool_memberships.count }.by(1)
    end

    it "should have the correct pool Id" do
      user2.pools << @pool2
      @pool_membership = user2.pool_memberships.find_by_pool_id(@pool2)
      expect(@pool_membership.pool_id).to eq @pool2.id
    end
  end

  describe "set_owner method" do

    it "should be able to set owner flag to true" do
      @pool_membership.owner = true
      expect(@pool_membership.owner).to eq true
    end
  end

  describe "when deleting a pool" do
    it "should remove an entry from pool_memberships" do
      expect do
        @pool1.destroy
      end.to change(PoolMembership, :count).by(-1)
    end
  end
end
