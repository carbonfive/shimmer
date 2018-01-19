require "bundler/setup"
require "shimmer"
require "capybara/rspec"
require "pry"
require "awesome_print"
require 'selenium/webdriver'
require 'capybara/poltergeist'

require_relative "../benchmark/fixture_server"

fixture_server = FixtureServer.new

Capybara.register_driver :shimmer do |app|
  Capybara::Shimmer::Driver.new(app, use_proxy: true, headless: true)
end

Capybara.register_driver :headless_chrome do |app|
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    chrome_options: { "args" => %w[headless] }
  )
  Capybara::Selenium::Driver.new(
    app,
    browser: :chrome,
    desired_capabilities: capabilities
  )
end

# Capybara.current_driver = :poltergeist
# Capybara.default_driver = :poltergeist
Capybara.current_driver = :shimmer
Capybara.default_driver = :shimmer

Capybara.app_host = "http://localhost:#{fixture_server.port}"
Capybara.run_server = false

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before :suite do
    fixture_server.start!
  end

  config.after :suite do
    fixture_server.stop!
  end
end
