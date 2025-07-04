require 'rails_helper'

feature 'User can sign up', "
  In order to ask question
  As an unauthenticated user
  I'd like to be able to sign up
" do
  given(:user) { create(:user) }

  background { visit new_user_registration_path }

  scenario 'Registered user tries to sign up' do
    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    fill_in 'Password confirmation', with: user.password
    click_on 'Sign up'

    expect(page).to have_content 'Email has already been taken'
  end

  scenario 'Unregistered user tries to sign up' do
    fill_in 'Email', with: 'user@test.ru'
    fill_in 'Password', with: '87654321'
    fill_in 'Password confirmation', with: '87654321'
    click_on 'Sign up'

    expect(page).to have_content 'A message with a confirmation link has been sent to your email address.'\
      ' Please follow the link to activate your account.'
  end
end
