require 'rails_helper'

feature 'User can vote for question', "
  In order to rate useful questions
  As an authenticated user
  I'd like to be able to vote up or down for a question
" do
  given(:user) { create(:user) }
  given(:author) { create(:user) }
  given!(:question) { create(:question, author: author) }

  background do
    sign_in(user)
    visit question_path(question)
  end

  scenario 'User votes up', :js do
    within '.question .vote-controls' do
      find('.upvote').click
      expect(page).to have_content '1'
    end
  end

  scenario 'User votes down', :js do
    within '.question .vote-controls' do
      find('.downvote').click
      expect(page).to have_content '-1'
    end
  end

  scenario 'User cancels vote', :js do
    within '.question .vote-controls' do
      find('.upvote').click
      find('.cancel-vote').click
      expect(page).to have_content '0'
    end
  end
end
