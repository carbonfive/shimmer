require "spec_helper"

RSpec.describe "RSpec matcher DSL", type: :feature do
  before do
  end

  describe "#has_content?" do
    it "does not return text in script tags" do
      visit "/script_tags.html"
      expect(page).to_not have_content("This text is in a script tag")
    end

    it "matches with page text" do
      visit "/index.html"
      expect(page).to have_content("CSS Zen Garden")
    end

    it "finds text that is deferred" do
      visit "/deferred_page_render.html"
      Capybara.using_wait_time 5 do
        expect(page).to have_content("New Page Content")
      end
    end

    it "finds text with manual override" do
      visit "/deferred_page_render.html"
      expect(page).to have_content("New Page Content", wait: 4)
    end
  end
end
