require 'rails_helper'

RSpec.describe Subscription, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:question) }
  end

  describe 'validations' do
    it 'validates uniqueness of user scoped to question' do
      user     = create(:user)
      question = create(:question, author: create(:user))

      create(:subscription, user: user, question: question)
      duplicate_subscription = build(:subscription, user: user, question: question)

      expect(duplicate_subscription).not_to be_valid
      expect(duplicate_subscription.errors[:user_id]).to include('has already been taken')
    end
  end
end
