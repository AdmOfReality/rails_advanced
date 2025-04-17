require 'rails_helper'

RSpec.describe RewardsController, type: :controller do
  let(:user) { create(:user) }

  before { login(user) }

  describe 'GET #index' do
    let(:question) { create(:question, author: user) }
    let!(:reward) { create(:reward, user: user, question: question, title: 'Super Star') }

    it 'populates an array of rewards for current user' do
      get :index
      expect(assigns(:rewards)).to contain_exactly(reward)
    end

    it 'renders the index template' do
      get :index
      expect(response).to render_template :index
    end
  end
end
