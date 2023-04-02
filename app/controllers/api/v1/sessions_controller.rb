class Api::V1::SessionsController < ApplicationController
  def create
    user = User.find_by(email: params[:email])

    if user && user.authenticate(params[:password])
      render json: { data: { api_token: user.api_token } }
    else
      render json: { error: 'Invalid email or password' }, status: :unauthorized
    end
  end
end
