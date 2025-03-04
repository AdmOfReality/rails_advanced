require 'rails_helper'

feature 'User can edit his answer', "
  In order to coorect mistakes
  As an author of answer
  I'd like to be able to edit my answer
" do
  given!(:users) { create_list(:user, 2) }
  given!(:question) { create(:question, author: users.first) }
  given!(:answer) { create(:answer, question: question, author: users.first) }

  describe 'Authenticated user', js: true do
    background do
      sign_in(users.first)

      visit question_path(question)
    end

    scenario 'edits his answer' do
      within '.answers' do
        click_on 'Edit'
        fill_in 'Body', with: 'Edited Answer'
        click_on 'Save'

        expect(page).not_to have_content answer.body
        expect(page).to have_content 'Edited Answer'
        expect(page).not_to have_selector 'textarea'
      end
    end

    scenario 'edits his answer with errors' do
      within '.answers' do
        click_on 'Edit'
        find_field('Body').set('')
        click_on 'Save'
      end

      expect(page).to have_content "Body can't be blank"
    end

    scenario "tries to edit other user's answer" do
      click_on 'Logout'
      sign_in(users.last)
      visit question_path(question)

      question.answers.each do |answer|
        next if answer.author == users.last

        within "#answer_#{answer.id}" do
          expect(page).to_not have_link 'Edit'
        end
      end
    end
  end

  scenario 'Unauthenticated user can not to edit answer' do
    visit question_path(question)

    expect(page).not_to have_link 'Edit'
  end
end
