class AddPoolDoneToPool < ActiveRecord::Migration
  def change
    add_column :pools, :pool_done, :boolean, default: false
  end
end
