class ChangeWakeTimeToNullable < ActiveRecord::Migration[7.0]
  def change
    change_column :sleep_records, :wake_time, :datetime, null: true
  end
end
