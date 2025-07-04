require 'rails_helper'

RSpec.describe OauthCallbacksController, type: :controller do
  before do
    request.env['devise.mapping'] = Devise.mappings[:user]
  end

  let(:email) { 'test@example.com' }
  let(:oauth_data) do
    OmniAuth::AuthHash.new(
      provider: 'github',
      uid: '123',
      info: { email: email }
    )
  end

  describe 'GET #github' do
    context 'when user is found and confirmed' do
      let!(:user) { create(:user, email: email, confirmed_at: Time.current) }

      before do
        allow(request.env).to receive(:[]).and_call_original
        allow(request.env).to receive(:[]).with('omniauth.auth').and_return(oauth_data)
        allow(FindForOauth).to receive(:new).and_return(double(call: user))
        get :github
      end

      it 'signs in the user' do
        expect(subject.current_user).to eq user
      end

      it 'redirects to root_path' do
        expect(response).to redirect_to root_path
      end
    end

    context 'when user is found but not confirmed' do
      let!(:user) { create(:user, email: email, confirmed_at: nil) }

      before do
        allow(request.env).to receive(:[]).and_call_original
        allow(request.env).to receive(:[]).with('omniauth.auth').and_return(oauth_data)
        allow(FindForOauth).to receive(:new).and_return(double(call: user))
        get :github
      end

      it 'does not sign in the user' do
        expect(subject.current_user).to be_nil
      end

      it 'redirects to new_user_confirmation_path' do
        expect(response).to redirect_to new_user_confirmation_path
      end
    end

    context 'when provider does not return email' do
      let(:oauth_data) do
        OmniAuth::AuthHash.new(
          provider: 'github',
          uid: '123',
          info: {}
        )
      end

      before do
        allow(request.env).to receive(:[]).and_call_original
        allow(request.env).to receive(:[]).with('omniauth.auth').and_return(oauth_data)
        allow(FindForOauth).to receive(:new).and_return(double(call: :no_email))
        get :github
      end

      it 'redirects to new_oauth_email_path' do
        expect(response).to redirect_to new_oauth_email_path
      end

      it 'does not sign in the user' do
        expect(subject.current_user).to be_nil
      end
    end

    context 'when user is not found (FindForOauth returns nil)' do
      before do
        allow(request.env).to receive(:[]).and_call_original
        allow(request.env).to receive(:[]).with('omniauth.auth').and_return(oauth_data)
        allow(FindForOauth).to receive(:new).and_return(double(call: nil))
        get :github
      end

      it 'does not sign in the user' do
        expect(subject.current_user).to be_nil
      end

      it 'redirects to new_user_confirmation_path' do
        expect(response).to redirect_to new_user_confirmation_path
      end
    end
  end
end
