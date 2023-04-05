class Api::V1::BaseController < ApplicationController
  before_action :authenticate

  private

  def authenticate
    raise AuthenticationError::Unauthorized unless current_user
  end

  def current_user
    @current_user ||= User.find_by(api_token: auth_token)
  end

  def auth_token
    pattern = /^Bearer /
    header  = request.headers['Authorization']
    header.gsub(pattern, '') if header && header.match(pattern)
  end
end
