describe User, type: :model do
  let(:user) { create(:user) }

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should validate_presence_of(:password_digest) }
    it { should validate_length_of(:password).is_at_least(6) }
  end

  describe '#authenticate' do
    context 'with valid password' do
      it 'returns the user' do
        expect(user.authenticate('password')).to eq(user)
      end
    end

    context 'with invalid password' do
      it 'returns false' do
        expect(user.authenticate('invalid_password')).to eq(false)
      end
    end
  end

  describe "follow" do
    context "when following a user" do
      it "should follow the user" do
        user1 = create(:user)
        user2 = create(:user)
        user1.follow(user2)
        expect(user1.following?(user2)).to be true
      end
    end

    context "when already following a user" do
      it "should not follow the user again" do
        user1 = create(:user)
        user2 = create(:user)
        user1.follow(user2)

        expect { user1.follow(user2) }.not_to change { user1.followed_users.count }
      end
    end
  end

  describe "unfollow" do
    context "when unfollowing a user" do
      it "should unfollow the user" do
        user1 = create(:user)
        user2 = create(:user)
        user1.follow(user2)
        user1.unfollow(user2)
        expect(user1.following?(user2)).to be false
      end
    end

    context "when not following a user" do
      it "should not unfollow the user" do
        user1 = create(:user)
        user2 = create(:user)
        expect { user1.unfollow(user2) }.not_to change { user1.followed_users.count }
      end
    end
  end
end
