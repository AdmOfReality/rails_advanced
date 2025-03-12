require 'rails_helper'

feature 'User can delete own question', "
  In order to remove an outdated information
  As an authenticated user
  I'd like to be able to delete my own question
" do
  given(:user) { create(:user) }
  given!(:question) { create(:question, author: user) }

  describe 'Authenticated user' do
    background do
      sign_in(user)
      visit question_path(question)
    end

    scenario 'Author of question delete own question', :js do
      accept_confirm do
        click_on 'Delete question'
      end

      expect(page).to have_content 'Your question was successfully deleted.'
      expect(page).not_to have_content question.title
      expect(page).not_to have_content question.body
    end
  end

  scenario 'Non-author of question tries to delete question' do
    other_user = create(:user)
    sign_in(other_user)
    visit question_path(question)

    expect(page).not_to have_link 'Delete question'
  end

  scenario 'Unauthenticated user tries to delete question' do
    visit question_path(question)

    expect(page).not_to have_link 'Delete question'
  end
end
