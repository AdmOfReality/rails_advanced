FactoryBot.define do
  factory :comment do
    body { "MyText" }
    user { nil }
    commentable { nil }
  end
end
