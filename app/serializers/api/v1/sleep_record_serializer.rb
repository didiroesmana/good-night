class Api::V1::SleepRecordSerializer < ActiveModel::Serializer
  attributes :user, :bed_time, :wake_time, :created_at, :sleep_length

  def user
    Api::V1::UserSerializer.new(object.user).attributes
  end
end
