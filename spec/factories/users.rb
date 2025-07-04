FactoryBot.define do
  sequence :email do |n|
    "user#{n}@test.com"
  end

  factory :user do
    email
    password { 'LUCKYsilence^7' }
    password_confirmation { 'LUCKYsilence^7' }
    confirmed_at { Time.zone.now }
  end
end
