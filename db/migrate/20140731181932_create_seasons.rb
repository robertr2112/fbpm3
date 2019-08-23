class CreateSeasons < ActiveRecord::Migration
  def change
    create_table :seasons do |t|
      t.string :year
      t.integer :state
      t.boolean :nfl_league
      t.integer :number_of_weeks
      t.integer :current_week

      t.timestamps
    end
  end
end
