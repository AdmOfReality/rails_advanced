require 'rails_helper'

RSpec.describe QuestionsController, type: :controller do
  let(:author)   { create(:user) }
  let(:user)     { create(:user) }
  let(:question) { create(:question, author: author) }

  describe 'POST #subscribe' do
    before { login(user) } # ← используем твой хелпер

    it 'creates a subscription and renders subscribe template' do
      expect do
        post :subscribe, params: { id: question.id }, format: :js
      end.to change(Subscription, :count).by(1)

      expect(response).to have_http_status(:created).or have_http_status(:ok)
      expect(response).to render_template(:subscribe)
    end
  end

  describe 'DELETE #unsubscribe' do
    before do
      login(user)
      user.subscriptions.create!(question: question)
    end

    it 'destroys a subscription and renders unsubscribe template' do
      expect do
        delete :unsubscribe, params: { id: question.id }, format: :js
      end.to change(Subscription, :count).by(-1)

      expect(response).to have_http_status(:ok)
      expect(response).to render_template(:unsubscribe)
    end
  end
end
