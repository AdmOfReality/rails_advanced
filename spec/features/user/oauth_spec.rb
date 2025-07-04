require 'rails_helper'

feature 'User can sign in via social networks', "
  In order to simplify sign in process
  As an unauthenticated and authenticated user
  I'd like to be able to sign in with my social network accounts
 " do
  describe 'New user' do
    background { visit new_user_session_path }

    scenario 'tries to sign in via GitHub', :js do
      oauth_response(provider: :github)
      click_on 'Sign in with GitHub'

      expect(page).to have_content 'Successfully authenticated from Github account.'
    end

    scenario 'tries to sign in via Facebook', :js do
      oauth_response(provider: :facebook)
      click_on 'Sign in with Facebook'

      expect(page).to have_content 'Successfully authenticated from Facebook account.'
    end
  end

  describe 'Existing user' do
    given!(:user) { create(:user, email: 'user@example.com') }

    background { visit new_user_session_path }

    scenario 'tries to sign in via GitHub', :js do
      oauth_response(provider: :github)
      click_on 'Sign in with GitHub'

      expect(page).to have_content 'Successfully authenticated from Github account.'
    end

    scenario 'tries to sign in via Facebook', :js do
      oauth_response(provider: :facebook)
      click_on 'Sign in with Facebook'

      expect(page).to have_content 'Successfully authenticated from Facebook account.'
    end
  end
end
