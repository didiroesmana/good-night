class User < ApplicationRecord
  has_secure_password

  validates :name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :password_digest, presence: true
  validates :password, length: { minimum: 6 }, allow_nil: true
  validates :api_token, presence: true, uniqueness: { case_sensitive: true }

  before_validation :generate_api_token, on: :create

  def generate_api_token
    self.api_token = SecureRandom.hex(32)
  end

  def authenticate(password)
    if BCrypt::Password.new(password_digest) == password
      return self
    else
      return false
    end
  end
end
