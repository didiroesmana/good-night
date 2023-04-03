class Api::V1::SleepRecordsController < Api::V1::BaseController
  def create
    sleep_record = current_user.sleep_records.build(sleep_record_params)

    if sleep_record.save
      render json: { data: ActiveModelSerializers::SerializableResource.new(sleep_record, each_serializer: Api::V1::SleepRecordSerializer).as_json }, status: :created
    else
      render json: { errors: sleep_record.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def my_sleep_records
    sleep_records = current_user.sleep_records.order(created_at: :desc)
    render json: { data: ActiveModelSerializers::SerializableResource.new(sleep_records, each_serializer: Api::V1::SleepRecordSerializer) }, status: :ok
  end

  def index
    user = current_user
    friends = user.followed_users

    # Calculate the date range for the past week
    end_date = Date.current
    start_date = 1.week.ago.to_date

    # Get the sleep records for the past week for each friend
    sleep_records = []
    friends.each do |friend|
      friend_sleep_records = friend.sleep_records.where(bed_time: start_date.beginning_of_day..end_date.end_of_day)
      sleep_records.concat(friend_sleep_records)
    end

    # Sort the sleep records by the length of the sleep
    sorted_sleep_records = sleep_records.sort_by { |record| record.sleep_length }.reverse

    # Render the sleep records as JSON
    render json: { data: ActiveModelSerializers::SerializableResource.new(sorted_sleep_records, each_serializer: Api::V1::SleepRecordSerializer).as_json } , status: :ok
  end

  private

  def sleep_record_params
    params.require(:sleep_record).permit(:bed_time, :wake_time)
  end
end
