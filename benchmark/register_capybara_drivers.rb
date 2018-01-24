require "selenium/webdriver"
require "capybara/poltergeist"

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app)
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

Capybara.register_driver :chrome do |app|
  Capybara::Selenium::Driver.new(
    app,
    browser: :chrome
  )
end

Capybara.register_driver :shimmer do |app|
  Capybara::Shimmer::Driver.new(app, use_proxy: false, port: 9228)
end

Capybara.register_driver :headless_shimmer do |app|
  Capybara::Shimmer::Driver.new(app, headless: true, use_proxy: false, port: 9229)
end
