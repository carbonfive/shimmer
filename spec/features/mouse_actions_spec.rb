require "spec_helper"

RSpec.describe "mouse actions", type: :feature do
  before do
    visit "/mouse.html"
  end

  describe "hovering" do
    it "hovers over an element" do
      expect(page).to_not have_selector('.mouse-hover-target:hover')
      find('.mouse-hover-target').hover
      expect(page).to have_selector('.mouse-hover-target:hover')
    end
  end
end
