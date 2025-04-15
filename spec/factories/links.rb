FactoryBot.define do
  factory :link do
    name { "MyLink" }
    url { "http://example.com" }

    association :linkable, factory: :question
  end
end
