class User < ApplicationRecord
  has_secure_password

  has_many :following_relationships, foreign_key: :follower_id, dependent: :destroy
  has_many :followed_users, through: :following_relationships, source: :followed_user
  has_many :sleep_records

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

  def follow(other_user)
    following_relationships.create(followed_user: other_user) unless following?(other_user)
  end

  def unfollow(other_user)
    following_relationships.find_by(followed_user: other_user).destroy if following?(other_user)
  end

  def following?(other_user)
    followed_users.include?(other_user)
  end
end
