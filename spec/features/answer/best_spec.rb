require 'rails_helper'

feature 'User can choose the best answer', "
  In order to appreciate the help of other users
  And help community spot the best answer right away,
  As an author of the question
  I'd like to be able to choose the best answer
" do
  given!(:user) { create(:user) }
  given!(:user2) { create(:user) }
  given!(:user3) { create(:user) }
  given!(:question) { create(:question, author: user) }
  given!(:answers) { create_list(:answer, 2, question: question, author: user2) }
  given!(:other_answers) { create_list(:answer, 2, question: question, author: user3) }

  scenario 'Unauthenticated user can not choose best answer' do
    visit question_path(question)

    within '.answers' do
      expect(page).not_to have_link 'Best answer'
    end
  end

  describe 'Authenticated user', :js do
    describe 'as an author of the question' do
      background do
        sign_in(user)

        visit question_path(question)
      end

      scenario 'chooses best answer of the question' do
        within "#answer_#{answers.last.id}" do
          click_on 'Best answer'

          expect(page).not_to have_link 'Best answer'
          expect(page).to have_content 'It is the best answer.'
        end

        within "#answer_#{answers.first.id}" do
          expect(page).to have_link 'Best answer'
        end

        within '.answers' do
          expect(page).to have_css('strong', text: 'It is the best answer.', count: 1)
        end
      end
    end

    describe 'as not an author of the question' do
      background do
        sign_in(user2)

        visit question_path(question)
      end

      scenario "chooses best answer within other user's question" do
        within '.answers' do
          expect(page).not_to have_link 'Best answer'
        end
      end
    end
  end
end
