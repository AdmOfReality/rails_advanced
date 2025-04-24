require 'rails_helper'

feature 'User can delete own questions links', "
  In order to remove an outdated information
  As an authenticated user
  I'd like to be able to delete my own questions links
" do
  given(:user) { create(:user) }
  given(:question) { create(:question, author: user) }
  given!(:link) { create(:link, linkable: question) }

  scenario 'Author deletes link', :js do
    sign_in(user)
    visit question_path(question)

    within '.links_question' do
      within "#question_link_#{link.id}" do
        accept_confirm do
          click_on 'Delete'
        end
      end
    end

    expect(page).not_to have_content link.name
  end

  scenario "Non-author can't delete link", :js do
    non_author = create(:user)
    sign_in(non_author)
    visit question_path(question)

    within '.question' do
      within "#question_link_#{link.id}" do
        expect(page).not_to have_link 'Delete'
      end
    end
  end
end
