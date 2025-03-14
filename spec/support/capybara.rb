require 'selenium/webdriver'
require 'rails_helper'

Capybara.register_driver :selenium_firefox_headless do |app|
  options = Selenium::WebDriver::Firefox::Options.new
  options.add_argument('--headless')
  options.add_argument('--disable-gpu')
  options.add_argument('--window-size=1400,1400')

  Capybara::Selenium::Driver.new(app, browser: :firefox, options: options)
end

Capybara.javascript_driver = :selenium_firefox_headless
