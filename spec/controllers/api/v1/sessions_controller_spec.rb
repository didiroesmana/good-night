describe Api::V1::SessionsController, type: :controller do
  let!(:user) { create(:user, email: "user@example.com", password: "password123") }

  describe "POST #create" do
    context "with valid credentials" do
      it "returns a valid api_token" do
        post :create, params: { email: user.email, password: "password123" }
        expect(response).to have_http_status(:success)
        expect(response_body[:data][:api_token]).to eq(user.api_token)
      end
    end

    context "with invalid credentials" do
      it "returns unauthorized error" do
        post :create, params: { email: user.email, password: "invalidpassword" }
        expect(response).to have_http_status(:unauthorized)
        expect(response_body[:error]).to eq("Invalid email or password")
      end
    end
  end
end
