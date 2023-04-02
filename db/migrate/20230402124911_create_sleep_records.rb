class CreateSleepRecords < ActiveRecord::Migration[7.0]
  def change
    create_table :sleep_records do |t|
      t.references :user, null: false, foreign_key: true
      t.datetime :bed_time, null: false
      t.datetime :wake_time, null: false

      t.timestamps

      t.index [:user_id, :bed_time]
      t.index [:user_id, :wake_time]
    end
  end
end
