require 'rails_helper'

feature 'User can add links to question', "
  In order to provide additional info o my question
  As an question's author
  I'd like to be able to add links
" do
  given(:user) { create(:user) }
  given(:gist_url) { 'https://gist.github.com/AdmOfReality/7db0869e1e821512c70c38c673c006d0' }

  describe 'User' do
    background do
      sign_in(user)
      visit questions_path
      click_on 'Ask question'

      fill_in 'Title', with: 'Test question'
      fill_in 'Body', with: 'Question text'
    end

    scenario 'adds link when asks question', :js do
      click_link 'Add link'
      fill_in 'Link name', with: 'My gist'
      fill_in 'Url', with: gist_url

      click_on 'Ask'

      expect(page).to have_link 'My gist', href: gist_url
    end

    scenario 'adds multiple links when creates question', :js do
      click_link 'Add link'
      within all('.nested-fields')[0] do
        fill_in 'Link name', with: 'First link'
        fill_in 'Url', with: gist_url
      end

      click_link 'Add link'
      within all('.nested-fields')[1] do
        fill_in 'Link name', with: 'Second link'
        fill_in 'Url', with: 'https://google.com'
      end

      click_on 'Ask'

      within '.question' do
        expect(page).to have_link 'First link', href: gist_url
        expect(page).to have_link 'Second link', href: 'https://google.com'
      end
    end

    scenario 'tries to add question with invalid link', :js do
      click_link 'Add link'
      within all('.nested-fields').last do
        fill_in 'Link name', with: 'Invalid link'
        fill_in 'Url', with: 'invalid-url'
      end

      click_on 'Ask'

      expect(page).to have_content 'must be valid'
      expect(page).not_to have_link 'Invalid link'
    end
  end
end
