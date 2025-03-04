require 'rails_helper'

feature 'User can edit his question', "
  In order to coorect mistakes
  As an author of question
  I'd like to be able to edit my question
" do
  given!(:users) { create_list(:user, 2) }
  given!(:question) { create(:question, author: users.first) }

  describe 'Authenticated user', js: true do
    background do
      sign_in(users.first)

      visit question_path(question)
    end

    scenario 'edits his question' do
      click_on 'Edit'

      within '.question' do
        fill_in 'Title', with: 'Edited title'
        fill_in 'Body', with: 'Edited question'
        click_on 'Save'

        expect(page).not_to have_content question.title
        expect(page).not_to have_content question.body
        expect(page).to have_content 'Edited question'
        expect(page).to have_content 'Edited title'
        expect(page).not_to have_selector 'textarea'
      end
    end

    scenario 'edits his questions with errors' do
      click_on 'Edit'

      within '.question' do
        find_field('Body').set('')
        click_on 'Save'
      end

      expect(page).to have_content "Body can't be blank"
    end

    scenario "tries to edit other user's question" do
      click_on 'Logout'
      sign_in(users.last)

      visit question_path(question)

      expect(page).to_not have_link 'Edit'
    end
  end

  scenario 'Unauthenticated user can not to edit question' do
    visit question_path(question)

    expect(page).not_to have_link 'Edit'
  end
end
