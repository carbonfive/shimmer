require "spec_helper"

RSpec.describe Capybara::Shimmer::Node do
  let(:browser) { instance_double(Capybara::Shimmer::Browser) }
  let(:driver) { instance_double(Capybara::Shimmer::Driver, browser: browser) }
  let(:native) { double(:native) }
  let(:mouse_driver) { instance_double(Capybara::Shimmer::MouseDriver).as_null_object }
  let(:keyboard_driver) { instance_double(Capybara::Shimmer::KeyboardDriver).as_null_object }
  let(:javascript_bridge) { instance_double(Capybara::Shimmer::JavascriptBridge).as_null_object }

  subject { described_class.new(driver, native) }

  before do
    allow(Capybara::Shimmer::JavascriptBridge).to receive(:new) { javascript_bridge }
    allow(Capybara::Shimmer::MouseDriver).to receive(:new) { mouse_driver }
    allow(Capybara::Shimmer::KeyboardDriver).to receive(:new) { keyboard_driver }
  end

  describe "#set" do
    context "when a text node" do
      it "delegates to the KeyboardDriver" do
        subject.set("hello")
        expect(javascript_bridge).to have_received(:evaluate_js)
          .exactly(2).times
      end
    end
  end

  describe '#hover' do
    it 'delegates to MouseDriver#move_to' do
      subject.hover
      expect(mouse_driver).to have_received(:move_to)
        .with(subject)
    end
  end
end
