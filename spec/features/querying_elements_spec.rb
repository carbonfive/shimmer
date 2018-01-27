require "spec_helper"

RSpec.describe "querying elements", type: :feature do
  before do
    visit "/index.html"
  end

  describe "#find" do
    it "finds a single CSS element" do
      result = find("h1")
      expect(result.tag_name).to eq "h1"
      expect(result.text).to eq "CSS Zen Garden"
    end

    it "finds by an XPath selector" do
      result = find(:xpath, "//h1")
      expect(result.tag_name).to eq "h1"
      expect(result.text).to eq "CSS Zen Garden"
    end

    it "finds with extra text selector" do
      result = find("li", text: "Mid Century Modern by Andrew Lohman")
      expect(result.text).to eq "Mid Century Modern by Andrew Lohman"
    end

    it "errors on ambiguous match" do
      expect {
        find("li")
      }.to raise_error(Capybara::Ambiguous)
    end

    it "finds :link_or_button" do
      result = find(:link_or_button, "CSS Resource Guide")
      expect(result.text).to eq "CSS Resource Guide"
    end

    it "does not find elements that are hidden" do
      expect {
        find(".should-be-hidden")
      }.to raise_error(Capybara::ElementNotFound)
    end
  end

  describe "#all" do
    it "finds multiple CSS elements" do
      expect(all("li").count).to eq 15
      expect(all("li").map(&:text)).to include "Mid Century Modern by Andrew Lohman"
    end

    it "allows scoped within queries" do
      within(".design-selection nav") do
        expect(all("li").count).to eq 8
      end
    end
  end
end
