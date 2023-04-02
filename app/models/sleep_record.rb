class SleepRecord < ApplicationRecord
  belongs_to :user

  validates :bed_time, presence: true
  validates :wake_time, presence: true

  validate :validate_bedtime_before_waketime
  validate :only_one_record_per_day

  def sleep_length
    ((wake_time - bed_time) / 60).to_i
  end

  private

  def validate_bedtime_before_waketime
    errors.add(:bedtime, "must be before wake_time") if bed_time && wake_time && bed_time >= wake_time
  end

  def only_one_record_per_day
    if SleepRecord.where(user_id: user_id, bed_time: bed_time.beginning_of_day..bed_time.end_of_day).exists? || SleepRecord.where(user_id: user_id, wake_time: wake_time.beginning_of_day..wake_time.end_of_day).exists?
      errors.add(:base, 'Only one sleep record is allowed per day.')
    end
  end
end
