require "spec_helper"

RSpec.describe "page navigation", type: :feature do
  it "allows me to click on link" do
    visit "/page_navigation.html"
    expect(page).to have_content "Page Navigation Test - Page 1"
    click_on "Go To Next Page"
    expect(page).to have_content "Page Navigation Test - Page 2"
    click_on "Go To Previous Page"
    expect(page).to have_content "Page Navigation Test - Page 1"
  end

  it "handles a redirect chain" do
    visit "/redirect_to_index.html"
    expect(page.current_path).to eq "/index.html"
  end
end
