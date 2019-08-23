class CreateEntries < ActiveRecord::Migration
  def change
    create_table :entries do |t|
      t.integer :pool_id
      t.integer :user_id
      t.string  :name
      t.boolean :survivorStatusIn, default: true
      t.integer :supTotalPoints, default: 0

      t.timestamps
    end
    add_index :entries, :pool_id
    add_index :entries, :user_id
  end
end
