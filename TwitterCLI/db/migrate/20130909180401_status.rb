class Status < ActiveRecord::Migration
  def change
    create_table :statuses do |t|
      t.string :body, :null => false
      t.integer :user_id, :null => false
      t.integer :twitter_status_id, :null => false, uniqueness: true

      t.timestamps
    end

    add_index(:statuses, :twitter_status_id)
    add_index(:statuses, :user_id)
  end
end
