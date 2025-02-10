require 'rails_helper'

feature 'The user can view the list of questions and answers to find suitable answers' do
  given(:user) { create(:user) }
  given!(:question) { create(:question, author: user) }
  given!(:answers) { create_list(:answer, 3, question: question, author: user) }

  scenario 'Authenticated user sees list of all answers' do
    sign_in(user)
    visit question_path(question)

    answers.each { |answer| expect(page).to have_content answer.body }
  end

  scenario 'Unauthenticated user sees list of all answers' do
    visit question_path(question)
    answers.each { |answer| expect(page).to have_content answer.body }
  end
end
