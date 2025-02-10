require 'rails_helper'

feature 'User can sign out', "
  In order end session
" do
  given(:user) { create(:user) }

  background { visit new_user_session_path }

  scenario 'Registered user tries to sign out' do
    sign_in(user)

    click_on 'Logout'

    expect(page).to have_content 'Signed out successfully.'
  end
end
