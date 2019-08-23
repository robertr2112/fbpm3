class CreateWeeks < ActiveRecord::Migration
  def change
    create_table :weeks do |t|
      t.belongs_to :season
      t.integer    :state
      t.integer    :week_number

      t.timestamps
    end
  end
end
