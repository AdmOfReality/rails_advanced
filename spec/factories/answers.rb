FactoryBot.define do
  sequence :body do |n|
    "Answer#{n}"
  end
  factory :answer do
    body

    trait :invalid do
      body { nil }
    end
  end
end
