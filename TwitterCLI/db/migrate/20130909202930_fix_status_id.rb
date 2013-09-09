class FixStatusId < ActiveRecord::Migration
  def up
    change_column :statuses, :twitter_status_id, :bigint
  end

  def down
    change_column :statuses, :twitter_status_id, :integer
  end
end
