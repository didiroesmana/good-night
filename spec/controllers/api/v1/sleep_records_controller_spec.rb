describe Api::V1::SleepRecordsController, type: :controller do
  describe "POST #create" do
    let(:user) { create(:user) }
    let(:valid_params) { { sleep_record: { bed_time: Time.current, wake_time: Time.current + 8.hours } } }
    let(:invalid_params) { { sleep_record: { bed_time: Time.current, wake_time: Time.current - 4.hours } } }
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

        it "returns status code 422" do
          post :create, params: invalid_params
          expect(response).to have_http_status(422)
        end

        it "returns a validation error message" do
          post :create, params: invalid_params
          expect(response_body[:errors][0]).to eq("Bedtime must be before wake_time")
        end
      end
    end

    context "when user is not authenticated" do
      it "returns status code 401" do
        post :create, params: valid_params
        expect(response).to have_http_status(401)
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
      create(:sleep_record, user: friend2, wake_time: Time.current + 1.hours)
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
