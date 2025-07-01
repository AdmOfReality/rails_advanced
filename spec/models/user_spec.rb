require 'rails_helper'

RSpec.describe User, type: :model do
  let(:users) { create_list(:user, 2) }

  describe 'associations' do
    it { should have_many(:answers).with_foreign_key('author_id').dependent(:destroy) }
    it { should have_many(:questions).with_foreign_key('author_id').dependent(:destroy) }
    it { should have_many(:authorizations).dependent(:destroy) }

  end

  describe 'validations' do
    it { should validate_presence_of :email }
    it { should validate_presence_of :password }
  end

  describe 'author_of? questions' do
    let(:question) { create(:question, author: users.first) }
    let(:other_question) { create(:question, author: users.last) }

    context 'when user is author' do
      it 'returns true' do
        expect(users.first.author_of?(question)).to be true
      end
    end

    context 'when user is not author' do
      it 'returns false' do
        expect(users.first.author_of?(other_question)).to be false
      end
    end
  end

  describe 'author_of? answer' do
    let(:question) { create(:question, author: users.first) }
    let(:answer) { create(:answer, question: question, author: users.first) }
    let(:other_answer) { create(:answer, question: question, author: users.last) }

    context 'when user is author' do
      it 'returns true' do
        expect(users.first.author_of?(answer)).to be true
      end
    end

    context 'when user is not author' do
      it 'returns false' do
        expect(users.first.author_of?(other_answer)).to be false
      end
    end
  end

  describe '.find_for_oauth' do
    let!(:user) { create(:user) }
    let(:auth) { OmniAuth::AuthHash.new(provider: 'facebook', uid: '123456') }

    context 'user already has authorization' do
      it 'returns the user' do
        user.authorizations.create(provider: 'facebook', uid: '123456')
        expect(User.find_for_oauth(auth)).to eq user
      end
    end

    context 'user has not authorization' do
      context 'user already exists' do
        let(:auth) { OmniAuth::AuthHash.new(provider: 'facebook', uid: '123456', info: { email: user.email }) }

        it 'does not create new user' do
          expect { User.find_for_oauth(auth) }.not_to change(User, :count)
        end

        it 'creates authorization for user' do
          expect { User.find_for_oauth(auth) }.to change(user.authorizations, :count).by(1)
        end

        it 'creates authorization with provider and uid' do
          authorization = User.find_for_oauth(auth).authorizations.first

          expect(authorization.provider).to eq auth.provider
          expect(authorization.uid).to eq auth.uid
        end

        it 'returns the user' do
          expect(User.find_for_oauth(auth)).to eq user
        end
      end

      context 'user does not exist' do
        let(:auth) { OmniAuth::AuthHash.new(provider: 'facebook', uid: '123456', info: { email: 'new@user.com' }) }

        it 'creates new user' do
          expect { User.find_for_oauth(auth) }.to change(User, :count).by(1)
        end

        it 'returns new user' do
          expect(User.find_for_oauth(auth)).to be_a(User)
        end

        it 'fills user email' do
          user = User.find_for_oauth(auth)
          expect(user.email).to eq auth.info[:email]
        end

        it 'creates authorization for user' do
          user = User.find_for_oauth(auth)
          expect(user.authorizations).not_to be_empty
        end

        it 'creates authorization with provider and uid' do
          authorization = User.find_for_oauth(auth).authorizations.first

          expect(authorization.provider).to eq auth.provider
          expect(authorization.uid).to eq auth.uid
        end
      end
    end
  end
end
