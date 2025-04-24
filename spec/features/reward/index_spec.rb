require 'rails_helper'

feature 'User views received rewards', '
  As a user
  I want to see rewards I received for best answers
' do
  given(:user) { create(:user) }
  given(:question) { create(:question, author: user) }
  given(:reward) { create(:reward, question: question, title: 'Golden Badge', user: user) }

  background do
    sign_in(user)
    reward.image.attach(io: File.open(Rails.root.join('spec/fixtures/files/reward.jpeg')), filename: 'reward.jpeg')
  end

  scenario 'User sees list of rewards' do
    visit rewards_path

    expect(page).to have_content 'Golden Badge'
    expect(page).to have_selector("img[src*='reward.jpeg']")
    expect(page).to have_link reward.question.title
  end
end
