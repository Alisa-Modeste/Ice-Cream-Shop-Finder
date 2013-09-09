class User < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :screen_name, :null => false, uniqueness: true
      t.integer :twitter_user_id, :null => false, uniqueness: true

      t.timestamps
    end
    add_index(:users, :twitter_user_id)

  end
end
