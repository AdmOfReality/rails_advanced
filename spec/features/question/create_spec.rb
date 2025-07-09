require 'rails_helper'

feature 'User can create question', "
  In order to get answer from a community
  As an authenticated user
  I'd like to be able to ask a question
" do
  given(:user) { create(:user) }

  describe 'Authenticated user' do
    background do
      sign_in(user)

      visit questions_path
      click_on 'Ask question'
    end

    scenario 'asks a question' do
      fill_in 'Title', with: 'Test question'
      fill_in 'Body', with: 'Question text'
      click_on 'Ask'

      expect(page).to have_content 'Your question successfully created.'
      expect(page).to have_content 'Test question'
      expect(page).to have_content 'Question text'
    end

    scenario 'asks a question with errors' do
      click_on 'Ask'

      expect(page).to have_content "Title can't be blank"
    end

    scenario 'asks a question with attached files' do
      fill_in 'Title', with: 'Test question'
      fill_in 'Body', with: 'Question text'

      attach_file 'File', [Rails.root.join('spec/rails_helper.rb').to_s, Rails.root.join('spec/spec_helper.rb').to_s]
      click_on 'Ask'
      within '.question' do
        expect(page).to have_link 'rails_helper.rb'
        expect(page).to have_link 'spec_helper.rb'
      end
    end

    scenario 'asks a question with reward' do
      fill_in 'Title', with: 'Test question with reward'
      fill_in 'Body', with: 'Question body with reward'

      fill_in 'Reward title', with: 'Best Answer Prize'
      attach_file 'Image', Rails.root.join('spec/fixtures/files/reward.jpeg')

      click_on 'Ask'

      expect(page).to have_content 'Your question successfully created.'
      expect(Reward.last.title).to eq 'Best Answer Prize'
      expect(Reward.last.image).to be_attached
    end
  end

  scenario 'Unauthenticated user have no link Ask question' do
    visit questions_path

    expect(page).to have_no_link 'Ask question'
  end
end
