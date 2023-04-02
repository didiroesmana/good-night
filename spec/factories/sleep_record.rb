FactoryBot.define do
  factory :sleep_record do
    user
    bed_time { Time.current }
    wake_time { bed_time + 8.hours }
  end
end
