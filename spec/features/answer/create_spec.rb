require 'rails_helper'

feature 'User can answer to question', "
  In order to provide answer for the community
  As an authenticated user
  I'd like to be able to answer a questions
" do
  given(:user) { create(:user) }
  given!(:question) { create(:question, author: user) }

  describe 'Authenticated user', js: true do
    background do
      sign_in(user)

      visit question_path(question)
    end

    scenario 'gives an answer' do
      fill_in 'Body', with: 'Answer text'
      click_on 'Answer'

      expect(current_path).to eq question_path(question)
      within '.answers' do
        expect(page).to have_content 'Answer text'
      end
    end

    scenario 'gives an answer with errors' do
      click_on 'Answer'

      expect(page).to have_content "Body can't be blank"
    end
  end

  scenario 'Unauthenticated user tries to answers question' do
    visit question_path(question)

     expect(page).not_to have_css('form.new_answer')
  end
end
