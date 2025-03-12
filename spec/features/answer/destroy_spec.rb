require 'rails_helper'

feature 'User can delete own answer', "
  In order to remove an outdated information
  As an authenticated user
  I'd like to be able to delete my own answer
" do
  given(:user) { create(:user) }
  given!(:question) { create(:question, author: user) }
  given!(:answers) { create_list(:answer, 2, question: question, author: user) }

  describe 'Authenticated user', :js do
    background do
      sign_in(user)
      visit question_path(question)
    end

    scenario 'Author of answer delete own answer' do
      within "#answer_#{answers.first.id}" do
        accept_confirm do
          click_on 'Delete answer'
        end
      end

      expect(page).not_to have_content answers.first.body
    end
  end

  scenario 'Non-author of answer tries to delete answer' do
    other_user = create(:user)
    sign_in(other_user)
    visit question_path(question)

    expect(page).not_to have_link 'Delete answer'
  end

  scenario 'Unauthenticated user tries to delete question' do
    visit question_path(question)

    expect(page).not_to have_link 'Delete answer'
  end
end
