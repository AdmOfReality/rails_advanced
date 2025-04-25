require 'rails_helper'

RSpec.describe VotesController, type: :controller do
  let(:author) { create(:user) }
  let(:user) { create(:user) }
  let(:question) { create(:question, author: author) }

  before { login(user) }

  describe 'POST #upvote' do
    context 'when valid' do
      it 'creates a new upvote' do
        expect do
          post :upvote, params: { votable_type: 'Question', votable_id: question.id }, format: :json
        end.to change(Vote, :count).by(1)
      end

      it 'returns 200 status' do
        post :upvote, params: { votable_type: 'Question', votable_id: question.id }, format: :json
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when double upvote' do
      before do
        create(:vote, votable: question, user: user, value: 1)
      end

      it 'does not create a new vote' do
        expect do
          post :upvote, params: { votable_type: 'Question', votable_id: question.id }, format: :json
        end.not_to change(Vote, :count)
      end

      it 'returns 422 status' do
        post :upvote, params: { votable_type: 'Question', votable_id: question.id }, format: :json
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'POST #downvote' do
    it 'creates a downvote' do
      expect do
        post :downvote, params: { votable_type: 'Question', votable_id: question.id }, format: :json
      end.to change(Vote, :count).by(1)
    end
  end

  describe 'DELETE #cancel' do
    let!(:vote) { create(:vote, votable: question, user: user, value: 1) }

    it 'cancels the vote' do
      expect do
        delete :cancel, params: { votable_type: 'Question', votable_id: question.id }, format: :json
      end.to change(Vote, :count).by(-1)
    end

    it 'returns 200 status' do
      delete :cancel, params: { votable_type: 'Question', votable_id: question.id }, format: :json
      expect(response).to have_http_status(:ok)
    end
  end
end
