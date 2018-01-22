require "spec_helper"

RSpec.describe Capybara::Shimmer::KeyboardDriver do
  subject { described_class.new(browser) }
  let(:browser) { instance_double(Capybara::Shimmer::Browser) }

  describe "#type" do
    it "programmatically sends keystrokes" do
      expect(browser)
        .to receive(:send_cmd)
        .with("Input.dispatchKeyEvent", anything)
        .exactly(5)
        .times
      subject.type("abcde")
    end
  end

  describe "#send_character" do
    it "sends a keycode event over the DevTools protocol" do
      expect(browser)
        .to receive(:send_cmd)
        .with("Input.dispatchKeyEvent",
              type: :char,
              text: "q",
              unmodifiedText: "q",
              key: "q")

      subject.send_character("q")
    end
  end
end
