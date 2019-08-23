class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string   :name
      t.string   :user_name
      t.string   :email
      t.boolean  :admin, default: false
      t.boolean  :supervisor, default: false
      t.string   :password_digest
      t.string   :remember_token
      t.string   :password_reset_token
      t.datetime :password_reset_sent_at
      t.boolean  :confirmed, default: false
      t.string   :confirmation_token

      t.timestamps
    end
    add_index :users, :email, unique: true
    add_index :users, :remember_token
  end
end
