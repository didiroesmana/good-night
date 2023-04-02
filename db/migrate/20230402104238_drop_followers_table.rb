class DropFollowersTable < ActiveRecord::Migration[7.0]
  def up
    drop_table :followers
  end
end
