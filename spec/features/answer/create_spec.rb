require 'rails_helper'

feature 'User can answer to question', "
  In order to provide answer for the community
  As an authenticated user
  I'd like to be able to answer a questions
" do
  given(:user) { create(:user) }
  given!(:question) { create(:question, author: user) }

  describe 'Authenticated user' do
    background do
      sign_in(user)

      visit question_path(question)
    end

    scenario 'gives an answer' do
      fill_in 'Body', with: 'Answer text'
      click_on 'Answer'

      expect(page).to have_content 'Your answer successfully created.'
      expect(page).to have_content 'Answer text'
    end

    scenario 'gives an answer with errors' do
      click_on 'Answer'

      expect(page).to have_content "Body can't be blank"
    end
  end

  scenario 'Unauthenticated user tries to answers question' do
    visit question_path(question)
    click_on 'Answer'

    expect(page).to have_content 'You need to sign in or sign up before continuing.'
  end
end
