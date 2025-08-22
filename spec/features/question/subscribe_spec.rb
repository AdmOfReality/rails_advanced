require 'rails_helper'

feature 'User can subscribe to question', "
  As an Authenticated user
  I'd like to be able to subscribe the question
  Receive email notifications of new answers
" do
  given(:author)   { create :user }
  given(:user)     { create :user }
  given!(:question) { create :question, author: author }

  describe 'Authenticated author of question', js: true do
    before do
      sign_in author
      visit question_path(question)
    end

    scenario 'subscribes to new answers' do
      expect(page).to have_link 'Subscribe'
      click_on 'Subscribe'
      expect(page).to have_link 'Unsubscribe'
    end

    scenario 'unsubscribes from new answers' do
      click_on 'Subscribe'
      click_on 'Unsubscribe'
      expect(page).to have_link 'Subscribe'
    end
  end

  describe 'Authenticated user', js: true do
    before do
      sign_in user
      visit question_path(question)
    end

    scenario 'subscribes to new answers' do
      click_on 'Subscribe'
      expect(page).to have_link 'Unsubscribe'
    end

    scenario 'unsubscribes from new answers' do
      click_on 'Subscribe'
      click_on 'Unsubscribe'
      expect(page).to have_link 'Subscribe'
    end
  end

  describe 'Guest' do
    scenario "can't subscribe" do
      visit question_path(question)
      expect(page).not_to have_link 'Subscribe'
      expect(page).not_to have_link 'Unsubscribe'
    end
  end
end
