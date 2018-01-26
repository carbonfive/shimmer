require "spec_helper"

RSpec.describe Capybara::Shimmer::KeyboardDriver do
  subject { described_class.new(browser) }
  let(:browser) { instance_double(Capybara::Shimmer::Browser) }

  describe "#type" do
    it "programmatically sends keystrokes" do
      expect(browser)
        .to receive(:send_cmd)
        .with("Input.dispatchKeyEvent", hash_including(key: "a"))
        .ordered
      expect(browser)
        .to receive(:send_cmd)
        .with("Input.dispatchKeyEvent", hash_including(key: "b"))
        .ordered
      subject.type("ab")
    end

    it "converts to string from int" do
      expect(browser)
        .to receive(:send_cmd)
        .with("Input.dispatchKeyEvent",
              type: :char,
              text: "9",
              unmodifiedText: "9",
              key: "9")
      subject.type(9)
    end

    it "converts to string from float" do
      expect(browser)
        .to receive(:send_cmd)
        .with("Input.dispatchKeyEvent", hash_including(key: "9"))
        .ordered
      expect(browser)
        .to receive(:send_cmd)
        .with("Input.dispatchKeyEvent", hash_including(key: "."))
        .ordered
      expect(browser)
        .to receive(:send_cmd)
        .with("Input.dispatchKeyEvent", hash_including(key: "0"))
        .ordered
      subject.type(9.0)
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
