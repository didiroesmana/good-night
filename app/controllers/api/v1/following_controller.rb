class Api::V1::FollowingController < Api::V1::BaseController
  before_action :validate_target_user, only: [:create, :destroy]

  def create
    followed_user = User.find(params[:id])
    current_user.follow(followed_user)
    render json: { message: "Successfully followed user with id #{followed_user.id}" }
  end

  def destroy
    followed_user = User.find(params[:id])
    current_user.unfollow(followed_user)
    render json: { message: "Successfully unfollowed user with id #{followed_user.id}" }
  end

  def validate_target_user
    @target_user = User.find_by(id: params[:id])
    unless @target_user
      render json: { error: "Target user not found" }, status: :not_found
    end
  end
end
