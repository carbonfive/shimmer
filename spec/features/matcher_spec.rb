require "spec_helper"

RSpec.describe "RSpec matcher DSL", type: :feature do
  before do
  end

  describe "#has_content?" do
    it "matches with page text" do
      visit "/index.html"
      expect(page).to have_content("CSS Zen Garden")
    end

    it "finds text that is deferred" do
      visit "/deferred_page_render.html"
      Capybara.using_wait_time 2 do
        expect(page).to have_content("New Page Content")
      end
    end

    it "finds text with manual override" do
      visit "/deferred_page_render.html"
      expect(page).to have_content("New Page Content", wait: 4)
    end
  end
end
