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
    let(:service) { double('FindForOauth') }

    it 'calls service FindForOauth' do
      expect(FindForOauth).to receive(:new).with(auth).and_return(service)
      expect(service).to receive(:call)
      User.find_for_oauth(auth)
    end
  end
end
