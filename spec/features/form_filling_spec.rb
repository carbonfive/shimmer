require "spec_helper"

RSpec.describe "form filling", type: :feature do
  before do
    visit "/form.html"
  end

  { text: "Artisanal kale" }.each do |input_type, initial_value|
    context "#{input_type} inputs" do
      let(:selector) { "#example-#{input_type}-input" }
      it "reads value" do
        result = find(selector)
        expect(result.value).to eq initial_value
      end

      it "sets value" do
        find(selector).set("Foobar")
        expect(find(selector).value).to eq "Foobar"
      end
    end
  end

  context "select dropdowns" do
  end
end
