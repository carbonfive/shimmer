require "spec_helper"

RSpec.describe "form filling", type: :feature do
  before do
    visit "/form.html"
  end

  { text: "Artisanal kale",
    email: "bootstrap@example.com"
  }.each do |input_type, initial_value|
    context "#{input_type} inputs" do
      let(:selector) { "#example-#{input_type}-input" }
      it "reads value" do
        result = find(selector)
        expect(result.value).to eq initial_value
      end

      it "sets value" do
        find(selector).set("Foobar")
        updated_result = find(selector)
        expect(updated_result.value).to eq "Foobar"
      end

      it "sends_keys to set value" do
        find(selector).send_keys("Foobar")
        updated_result = find(selector)
        expect(updated_result.value).to eq "Foobar"
      end

      context "via action DSL" do
        it "fills in" do
          fill_in("example-#{input_type}-input", with: 'Cruciferous veggies')
          expect(find(selector).value).to eq('Cruciferous veggies')
        end
      end
    end
  end

  context "select dropdowns" do
    it "reads value" do
      select_el = find("#exampleSelect1")
      expect(select_el.value).to eq "1"
    end

    context "via action DSL" do
      it "sets value" do
        select("2", from: "exampleSelect1")
        expect(find('#exampleSelect1').value).to eq "2"
      end
    end
  end
end
