require 'rails_helper'

feature 'User can delete own answer', "
  In order to remove an outdated information
  As an authenticated user
  I'd like to be able to delete my own answer
" do
  given(:user) { create(:user) }
  given!(:question) { create(:question, author: user) }
  given!(:answers) { create_list(:answer, 2, :with_files, question: question, author: user) }

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

    scenario 'author delete attached files' do
      attachment = answers.first.files.first

      within "#attachment_#{attachment.id}" do
        accept_confirm do
          click_on 'Delete attach'
        end

        expect(page).not_to have_css "#attachment_#{attachment.id}"
      end

      sleep 1
      expect(ActiveStorage::Attachment).not_to exist(attachment.id)
    end

    scenario 'non-author delete attached files' do
      click_on 'Logout'
      expect(page).to have_button('Login')
      other_user = create(:user)
      sign_in(other_user)
      visit question_path(question)
      attachment = answers.first.files.first

      within "#attachment_#{attachment.id}" do
        expect(page).not_to have_link 'Delete attach'
      end
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
