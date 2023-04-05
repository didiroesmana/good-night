class SleepRecord < ApplicationRecord
  belongs_to :user

  validates :bed_time, presence: true

  validate :cannot_create_record_if_previous_wake_time_null, on: :create
  validate :no_overlap, on: :create

  def sleep_length
    return 0 if wake_time.nil?
    ((wake_time - bed_time) / 60).to_i
  end

  private

  def cannot_create_record_if_previous_wake_time_null
    return unless user
    if user.sleep_records.where(wake_time: nil).exists?
      errors.add(:base, "Cannot create a new sleep record while the previous one is still not recorded.")
    end
  end

  def no_overlap
    return unless user && bed_time
    overlaps = user.sleep_records.where.not(id: id).where("(? BETWEEN bed_time AND wake_time)", bed_time)
    errors.add(:bed_time, "cannot overlap with an existing sleep record.") if overlaps.any?
  end
end
