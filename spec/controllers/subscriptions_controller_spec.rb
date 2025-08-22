require 'rails_helper'

RSpec.describe SubscriptionsController, type: :controller do
  let(:author) { create :user }
  let(:user) { create :user }
  let(:question) { create :question, author: author }

  describe 'POST #create' do
    let(:request_subscription) do
      post :create, params: {
        question_id: question.id
      }, format: :js
    end

    context 'user subscribed to question' do
      before { login user }

      it 'response OK' do
        request_subscription

        expect(response).to be_successful
      end

      it 'creates new subscription' do
        expect { request_subscription }.to change(user.subscriptions, :count).by(1)
      end

      it 'renders template create' do
        request_subscription

        expect(response).to render_template :create
      end
    end

    context 'guest can\'t subscribe' do
      it 'response 4xx' do
        request_subscription

        expect(response.status).to eq 401
      end

      it 'dosn\'t created new subscription' do
        expect { request_subscription }.not_to change(user.subscriptions, :count)
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:subscription) { create :subscription, user: user, question: question }

    let(:request_subscription) do
      delete :destroy, params: {
        id: subscription.id
      }, format: :js
    end

    context 'user unsubscribed from question' do
      before { login user }

      it 'deletes subscription' do
        expect { request_subscription }.to change(user.subscriptions, :count).by(-1)
      end

      it 'renders template destroy' do
        request_subscription

        expect(response).to render_template :destroy
      end
    end

    context 'guest can\'t unsubscribe' do
      it 'dosn\'t deleted subscription' do
        expect { request_subscription }.not_to change(Subscription, :count)
      end
    end
  end
end
