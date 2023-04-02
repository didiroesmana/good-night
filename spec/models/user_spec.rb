describe User, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should validate_presence_of(:password_digest) }
    it { should validate_length_of(:password).is_at_least(6) }
  end

  describe '#authenticate' do
    let(:user) { create(:user) }

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
end
