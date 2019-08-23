class CreateTeams < ActiveRecord::Migration
  def change
    create_table :teams do |t|
      t.string  :name
      t.boolean :nfl
      t.string  :imagePath

      t.timestamps
    end
  end
end
