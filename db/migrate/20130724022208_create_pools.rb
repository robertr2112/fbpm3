class CreatePools < ActiveRecord::Migration
  def change
    create_table :pools do |t|
      t.string     :name
      t.belongs_to :season
      t.integer    :poolType
      t.integer    :starting_week, default: 1
      t.boolean    :allowMulti, default: false
      t.boolean    :isPublic, default: true
      t.string     :password_digest

      t.timestamps
    end
  end
end
