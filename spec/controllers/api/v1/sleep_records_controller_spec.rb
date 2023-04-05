describe Api::V1::SleepRecordsController, type: :controller do
  describe "POST #create" do
    let(:user) { create(:user) }
    let(:valid_params) { { sleep_record: { bed_time: Time.current } } }
    let(:invalid_params) { { sleep_record: { wake_time: Time.current } } }
    let(:headers) { { "Authorization": "Bearer #{user.api_token}" } }

    context "when user is authenticated" do
      before { request.headers.merge!(headers) }

      context "with valid params" do
        it "creates a new sleep record" do
          expect {
            post :create, params: valid_params
          }.to change(SleepRecord, :count).by(1)
        end

        it "returns status code 201" do
          post :create, params: valid_params
          expect(response).to have_http_status(201)
        end
      end

      context "with invalid params" do
        it "does not create a new sleep record" do
          expect {
            post :create, params: invalid_params
          }.not_to change(SleepRecord, :count)
        end

        it "returns status code 400" do
          post :create, params: invalid_params
          expect(response).to have_http_status(400)
        end
      end

      context "user already finish record wake_time" do
        it "should be able create record for same day" do
          sleep_record = create(:sleep_record, user: user)
          latest_bed_time = sleep_record.wake_time + 2.minutes

          valid_params[:sleep_record][:bed_time] = latest_bed_time
          expect {
            post :create, params: valid_params
          }.to change(SleepRecord, :count).by(1)

          latest_sleep_record = SleepRecord.last
          expect(latest_sleep_record.bed_time).to eq(latest_bed_time)
        end
      end

      context "user already have bed_time recorded" do
        it "returns a validation error message" do
          create(:sleep_record, user: user, bed_time: Time.now, wake_time: nil)
          post :create, params: valid_params
          expect(response_body[:errors][0]).to eq("Cannot create a new sleep record while the previous one is still not recorded.")
        end
      end
    end

    context "when user is not authenticated" do
      it "returns status code 401" do
        post :create, params: valid_params
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "PUT #update" do
    let(:user) { create(:user) }
    let(:sleep_record) { create(:sleep_record, user: user, wake_time: nil) }
    let(:wake_time) { sleep_record.bed_time + 8.hours }
    let(:headers) { { "Authorization": "Bearer #{user.api_token}" } }
    let(:valid_params) {
      {
        id: sleep_record.id,
        sleep_record: {
          wake_time: wake_time
        },
      }
    }

    let(:invalid_params) {
      {
        id: "not-valid-record",
        sleep_record: {
          invalid_propery: wake_time
        },
      }
    }

    context "when user is authenticated" do
      before { request.headers.merge!(headers) }

      context "with valid params" do
        it "update the sleep record" do
          put :update, params: valid_params
          expect(sleep_record.reload.wake_time).to be_truthy
          expect(sleep_record.sleep_length).to be_truthy
        end
      end

      context "with invalid params" do
        it "does not update sleep record" do
          expect do
            invalid_params[:id] = sleep_record.id
            put :update, params: invalid_params
          end.not_to change(sleep_record.reload, :wake_time)
        end
      end
    end

    context "when user is not authenticated" do
      it "returns status code 401" do
        put :update, params: valid_params
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "GET #my_sleep_records" do
    let(:user) { create(:user) }
    let!(:sleep_record1) { create(:sleep_record, user: user, bed_time: 3.days.ago , wake_time: 3.days.ago + 4.hours, created_at: 3.days.ago) }
    let!(:sleep_record2) { create(:sleep_record, user: user, bed_time: 2.days.ago , wake_time: 2.days.ago + 5.hours, created_at: 2.day.ago) }
    let!(:sleep_record3) { create(:sleep_record, user: user, bed_time: Time.now , wake_time: nil) }
    let(:headers) { { "Authorization": "Bearer #{user.api_token}" } }

    before do
      request.headers.merge!(headers)
      get :my_sleep_records
    end

    it "returns HTTP success status" do
      expect(response).to have_http_status(:ok)
    end

    it "returns sleep records for the current user" do
      expect(response_body[:data]).to include(
        {
          bed_time: sleep_record1.bed_time.iso8601(3),
          wake_time: sleep_record1.wake_time.iso8601(3),
          created_at: sleep_record1.created_at.iso8601(3),
          sleep_length: sleep_record1.sleep_length,
          user: {
            id: user.id,
            name: user.name,
          }
        },
      )
    end

    it "returns sleep records in descending order of creation" do
      expect(response_body[:data]).to eq([
        {
          bed_time: sleep_record3.bed_time.iso8601(3),
          wake_time: nil,
          created_at: sleep_record3.created_at.iso8601(3),
          sleep_length: sleep_record3.sleep_length,
          user: {
            id: user.id,
            name: user.name,
          }
        },
        {
          bed_time: sleep_record2.bed_time.iso8601(3),
          wake_time: sleep_record2.wake_time.iso8601(3),
          created_at: sleep_record2.created_at.iso8601(3),
          sleep_length: sleep_record2.sleep_length,
          user: {
            id: user.id,
            name: user.name,
          }
        },
        {
          bed_time: sleep_record1.bed_time.iso8601(3),
          wake_time: sleep_record1.wake_time.iso8601(3),
          created_at: sleep_record1.created_at.iso8601(3),
          sleep_length: sleep_record1.sleep_length,
          user: {
            id: user.id,
            name: user.name,
          }
        },
      ])
    end
    
    context "when user is not authenticated" do
      it "returns status code 401" do
        request.headers.merge!({ "Authorization": "Bearer invalid-token" })
        get :my_sleep_records
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "GET #index" do
    let(:user) { create(:user) }
    let(:friend) { create(:user) }
    let(:friend2) { create(:user) }
    let(:friend3) { create(:user) }

    let(:headers) { { "Authorization": "Bearer #{user.api_token}" } }

    before do
      user.follow(friend)
      user.follow(friend2)
      create(:sleep_record, user: friend)
      create(:sleep_record, user: friend3)
      create(:sleep_record, user: friend2, bed_time: 1.day.ago, wake_time: 1.day.ago + 1.hours)
      create(:sleep_record, user: friend2, bed_time: 7.hours.ago, wake_time: nil)
      request.headers.merge!(headers)
    end

    it "returns sleep records of followed users only" do
      get :index
      expect(response_body[:data].length).to eq(2)
    end

    it "returns sleep records in order" do
      get :index
      expect(response_body[:data].length).to eq(2)
      expect(response_body[:data][0][:user][:id]).to eq(friend.id)
      expect(response_body[:data][1][:user][:id]).to eq(friend2.id)
    end
  end
end
