require "spec_helper"

RSpec.describe Capybara::Shimmer::Node do
  let(:browser) { double(Capybara::Shimmer::Browser) }
  let(:driver) { double(Capybara::Shimmer::Driver, browser: browser) }
  let(:native) { double(:native) }

  subject { described_class.new(driver, native) }

  describe "#set" do
    context "when a text node" do
      it "delegates to the KeyboardDriver" do
        expect_any_instance_of(Capybara::Shimmer::JavascriptBridge)
          .to receive(:evaluate_js)
          .at_least(2).times

        expect_any_instance_of(Capybara::Shimmer::KeyboardDriver)
          .to receive(:type)
          .with("hello")
        subject.set("hello")
      end
    end
  end
end
