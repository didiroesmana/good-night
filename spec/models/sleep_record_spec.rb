describe SleepRecord, type: :model do
  let(:user) { create(:user) }

  describe "validations" do
    it "is valid with valid attributes" do
      sleep_record = SleepRecord.new(bed_time: Time.now, user: user)
      expect(sleep_record).to be_valid
    end

    it "is invalid without a bed_time" do
      sleep_record = SleepRecord.new(user: user)
      expect(sleep_record).not_to be_valid
    end

    it "is invalid without a user" do
      sleep_record = SleepRecord.new(bed_time: Time.now)
      expect(sleep_record).not_to be_valid
    end

    it "is invalid if the bed_time overlaps with another sleep_record's bed_time" do
      existing_sleep_record = create(:sleep_record, user: user)
      sleep_record = SleepRecord.new(bed_time: existing_sleep_record.bed_time + 1.hour, user: user)
      expect(sleep_record).not_to be_valid
    end

    it "is valid if the bed_time does not overlap with another sleep_record's bed_time" do
      existing_sleep_record = create(:sleep_record, user: user)
      sleep_record = SleepRecord.new(bed_time: existing_sleep_record.bed_time + 9.hours, user: user)
      expect(sleep_record).to be_valid
    end

    it "is invalid if the bed_time overlap with another sleep_record's bed_time" do
      existing_sleep_record = create(:sleep_record, user: user)
      sleep_record = SleepRecord.new(bed_time: existing_sleep_record.bed_time + 2.hours, user: user)
      expect(sleep_record).not_to be_valid
    end
  end

  describe "methods" do
    it "calculates the sleep length in minutes" do
      sleep_record = create(:sleep_record, bed_time: Time.now - 8.hours, wake_time: Time.now + 1.second)
      expect(sleep_record.sleep_length).to eq(480)
    end

    it "returns 0 as the sleep length if the wake_time is nil" do
      sleep_record = create(:sleep_record, bed_time: Time.now - 8.hours, wake_time: nil)
      expect(sleep_record.sleep_length).to eq(0)
    end
  end
end
