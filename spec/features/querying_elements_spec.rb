require "spec_helper"

RSpec.describe "querying elements", type: :feature do
  before :each do
    visit '/index.html'
  end

  it "finds a single CSS element" do
    result = find('h1')
    expect(result).to have_content('CSS Zen Garden')
    expect(page).to have_selector('h1')
  end

  it "finds multiple CSS elements" do
    expect(all('li').count).to eq "15"
  end

  it "allows scoped within queries" do
  end
end
