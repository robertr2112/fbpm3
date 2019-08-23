class CreatePicks < ActiveRecord::Migration
  def change
    create_table :picks do |t|
      t.integer :week_id
      t.integer :entry_id
      t.integer :week_number
      t.integer :totalScore, default: 0

      t.timestamps
    end
    add_index :picks, :entry_id
  end
end
