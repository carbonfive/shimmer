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

  describe "#key_down" do
    it "sends a keycode" do
      expect(browser)
        .to receive(:send_cmd)
        .with("Input.dispatchKeyEvent",
              type: :keyDown,
              windowsVirtualKeyCode: 81,
              code: "KeyQ",
              text: "q",
              unmodifiedText: "q",
              location: 0,
              isKeypad: false,
              key: "q")

      subject.key_down("q")
    end
  end

  describe "#key_up" do
    it "sends a keycode" do
      expect(browser)
        .to receive(:send_cmd)
        .with("Input.dispatchKeyEvent",
              type: :keyUp,
              windowsVirtualKeyCode: 81,
              code: "KeyQ",
              text: "q",
              unmodifiedText: "q",
              location: 0,
              isKeypad: false,
              key: "q")

      subject.key_up("q")
    end
  end
end
