require 'rails_helper'

feature 'User can add links to answer', "
  In order to provide additional info to my answer
  As an answer's author
  I'd like to be able to add links
" do
  given(:user) { create(:user) }
  given!(:question) { create(:question, author: user) }
  given(:gist_url) { 'https://gist.github.com/AdmOfReality/7db0869e1e821512c70c38c673c006d0' }

  describe 'User' do
    background do
      sign_in(user)
      visit question_path(question)
    end

    scenario 'adds link when asks answer', :js do
      within 'form.new_answer' do
        fill_in 'Body', with: 'Answer text'
        click_on 'Add link'

        within all('.nested-fields').last do
          fill_in 'Link name', with: 'My gist'
          fill_in 'Url', with: gist_url
        end

        click_on 'Answer'
      end

      within '.answers' do
        expect(page).to have_link 'My gist', href: gist_url
      end
    end

    scenario 'adds multiple links when creates answer', :js do
      within '.new_answer' do
        fill_in 'Body', with: 'Answer text'

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

        click_on 'Answer'
      end

      within '.answers' do
        expect(page).to have_link 'First link', href: gist_url
        expect(page).to have_link 'Second link', href: 'https://google.com'
      end
    end

    scenario 'tries to add answer with invalid link', :js do
      within '.new_answer' do
        fill_in 'Body', with: 'Answer text'

        click_link 'Add link'
        within all('.nested-fields').last do
          fill_in 'Link name', with: 'Invalid link'
          fill_in 'Url', with: 'invalid-url'
        end

        click_on 'Answer'
      end

      expect(page).to have_content 'must be valid'
      expect(page).not_to have_link 'Invalid link'
    end
  end
end
