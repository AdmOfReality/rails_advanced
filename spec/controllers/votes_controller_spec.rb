require 'rails_helper'

RSpec.describe VotesController, type: :controller do
  let(:user) { create(:user) }
  let(:author) { create(:user) }
  let(:question) { create(:question, author: author) }

  before { login(user) }

  describe 'POST #upvote' do
    it 'creates vote and returns new rating' do
      post :upvote, params: { votable_type: 'Question', votable_id: question.id }, format: :json

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['rating']).to eq 1
    end
  end

  describe 'POST #downvote' do
    it 'creates vote and returns new rating' do
      post :downvote, params: { votable_type: 'Question', votable_id: question.id }, format: :json

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['rating']).to eq(-1)
    end
  end

  describe 'POST #cancel' do
    before do
      question.vote!(user, 1)
    end

    it 'cancels vote and returns updated rating' do
      post :cancel, params: { votable_type: 'Question', votable_id: question.id }, format: :json

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['rating']).to eq 0
    end
  end

  describe 'author cannot vote' do
    before { login(author) }

    it 'returns forbidden error' do
      post :upvote, params: { votable_type: 'Question', votable_id: question.id }, format: :json

      expect(response).to have_http_status(:forbidden)
      expect(JSON.parse(response.body)['error']).to eq 'You cannot vote for your own content'
    end
  end
end
