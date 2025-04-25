require 'rails_helper'

feature 'User can vote for answer', "
  In order to rate helpful answers
  As an authenticated user
  I'd like to be able to vote up or down for an answer
" do
  given(:user) { create(:user) }
  given(:author) { create(:user) }
  given(:question) { create(:question, author: author) }
  given!(:answer) { create(:answer, question: question, author: author) }

  background do
    sign_in(user)
    visit question_path(question)
  end

  scenario 'User votes up', :js do
    within "#answer_#{answer.id} .votes" do
      find('.upvote').click
      expect(page).to have_content '1'
    end
  end

  scenario 'User votes down', :js do
    within "#answer_#{answer.id} .votes" do
      find('.downvote').click
      expect(page).to have_content '-1'
    end
  end

  scenario 'User cancels their vote', :js do
    within "#answer_#{answer.id} .votes" do
      find('.upvote').click
      find('.cancel-vote').click
      expect(page).to have_content '0'
    end
  end

  scenario 'User cannot vote twice', :js do
    within "#answer_#{answer.id} .votes" do
      find('.upvote').click
      find('.upvote').click
      expect(page).to have_content '1' # всё равно 1, двойного голосования нет
    end
  end
end
