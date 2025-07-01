require 'rails_helper'

feature 'User can edit his answer', "
  In order to coorect mistakes
  As an author of answer
  I'd like to be able to edit my answer
" do
  given!(:users) { create_list(:user, 2) }
  given!(:question) { create(:question, author: users.first) }
  given!(:answer) { create(:answer, question: question, author: users.first) }

  describe 'Authenticated user', :js do
    background do
      sign_in(users.first)

      visit question_path(question)
    end

    scenario 'edits his answer' do
      within "#answer_#{answer.id}" do
        click_on 'Edit'
        fill_in 'Body', with: 'Edited Answer'
        click_on 'Save'
        sleep 1

        expect(page).not_to have_content answer.body
        expect(page).to have_content 'Edited Answer'
        # save_and_open_page
        # expect(page).not_to have_selector('textarea', wait: 3)
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
      expect(page).to have_button('Login')
      sign_in(users.last)
      visit question_path(question)

      question.answers.each do |answer|
        next if answer.author == users.last

        within "#answer_#{answer.id}" do
          expect(page).not_to have_link 'Edit'
        end
      end
    end

    scenario 'edits his answer with attached files' do
      within "#answer_#{answer.id}" do
        click_on 'Edit'
        attach_file 'File', [Rails.root.join('spec/models/answer_spec.rb').to_s, Rails.root.join('spec/models/question_spec.rb').to_s]
        click_on 'Save'
        expect(page).to have_link 'answer_spec.rb'
        expect(page).to have_link 'question_spec.rb'
      end
    end

    scenario 'edits his question with adding a link' do
      within "#answer_#{answer.id}" do
        click_on 'Edit'

        click_on 'Add link'

        within all('.nested-fields').last do
          fill_in 'Link name', with: 'My gist'
          fill_in 'Url', with: 'https://gist.github.com/AdmOfReality/7db0869e1e821512c70c38c673c006d0'
        end

        click_on 'Save'

        expect(page).to have_link 'My gist', href: 'https://gist.github.com/AdmOfReality/7db0869e1e821512c70c38c673c006d0'
        expect(page).to have_css '.gist-container'
      end
    end
  end

  scenario 'Unauthenticated user can not to edit answer' do
    visit question_path(question)

    expect(page).not_to have_link 'Edit'
  end
end
