FactoryBot.define do
  factory :question do
    title { 'MyString' }
    body { 'MyText' }
    association :author, factory: :user

    trait :invalid do
      title { nil }
    end

    trait :with_files do
      files do
        [
          Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files/example.txt'), 'text/plain'),
          Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files/example2.txt'), 'text/plain')
        ]
      end
    end
  end
end
