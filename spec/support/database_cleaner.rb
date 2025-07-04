RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.clean_with :truncation
  end

  config.before do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, :js) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before { DatabaseCleaner.start }
  config.after  { DatabaseCleaner.clean }
end
