describe Api::V1::FollowingController, type: :controller do
  let(:user) { create(:user) }
  let(:user_to_follow) { create(:user) }

  before do
    request.headers["Authorization"] = "Bearer #{user.api_token}"
  end

  describe "POST #create" do
    context "when following a user" do
      it "creates a new following relationship" do
        expect {
          post :create, params: { id: user_to_follow.id }
        }.to change(user.followed_users, :count).by(1)
      end

      it "returns a successful response" do
        post :create, params: { id: user_to_follow.id }
        expect(response).to have_http_status(:ok)
      end
    end

    context "when trying to follow the same user twice" do
      before do
        user.follow(user_to_follow)
      end

      it "does not create a new following relationship" do
        expect {
          post :create, params: { id: user_to_follow.id }
        }.not_to change(user.followed_users, :count)
      end
    end

    context "when trying to follow non exist user" do
      it "returns 404 if target user is not found" do
        post :create, params: { id: "non-exist-user" }
        expect(response).to have_http_status(:not_found)
      end
    end

    context "when token is invalid" do
      it "return a 401 Unathorized response" do
        request.headers["Authorization"] = "Bearer invalid-api-token"
        post :create, params: { id: user_to_follow.id }
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "DELETE #destroy" do
    context "when unfollowing a user" do
      before do
        user.follow(user_to_follow)
      end

      it "destroys the following relationship" do
        expect {
          delete :destroy, params: { id: user_to_follow.id }
        }.to change(user.followed_users, :count).by(-1)
      end

      it "returns a successful response" do
        delete :destroy, params: { id: user_to_follow.id }
        expect(response).to have_http_status(:ok)
      end
    end

    context "when trying to unfollow a user that the user is not following" do
      it "does not destroy any following relationship" do
        expect {
          delete :destroy, params: { id: user_to_follow.id }
        }.not_to change(user.followed_users, :count)
      end
    end

    context "when trying to unfollow non exist user" do
      it "eturns 404 if target user is not found" do
        delete :destroy, params: { id: "non-exist-user" }
        expect(response).to have_http_status(:not_found)
      end
    end

    context "when token is invalid" do
      it "return a 401 Unathorized response" do
        request.headers["Authorization"] = "Bearer invalid-api-token"
        delete :destroy, params: { id: user_to_follow.id }
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
