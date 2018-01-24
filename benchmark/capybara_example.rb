require "capybara/dsl"

module CapybaraExample
  extend Capybara::DSL

  def self.run(driver, fixture_server)
    Capybara.current_driver = driver
    Capybara.app_host = "http://localhost:#{fixture_server.port}"
    Capybara.run_server = false
    visit("index.html")
    find("li.css-resources").text
    find_all("nav[role=navigation] a").map { |el| el[:href] }
    1.times do
      click_on "Mid Century Modern"
      find('h1', text: "Mid Century Modern")
      click_on "Go back"
    end
    Capybara.reset_sessions!
  end
end

