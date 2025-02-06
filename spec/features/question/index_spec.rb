require 'rails_helper'

feature 'User can view list of questions', "
  In order to view question
" do
  given(:user) { create(:user) }
  given!(:questions) { create_list(:question, 3, author: user) }

  scenario 'Authenticated user can view list of questions' do
    sign_in(user)
    visit questions_path

    questions.each { |question| expect(page).to have_content question.title }
  end

  scenario 'Unauthenticated user can view list of questions' do
    visit questions_path

    questions.each { |question| expect(page).to have_content question.title }
  end
end
