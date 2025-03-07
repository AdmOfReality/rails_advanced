FactoryBot.define do
  sequence :body do |n|
    "Answer#{n}"
  end
  factory :answer do
    body

    trait :invalid do
      body { nil }
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
