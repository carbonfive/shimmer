require "json"

class Capybara::Shimmer::KeyboardDriver
  KEYBOARD_LAYOUT_PATH = "./data/us_keyboard_layout.json".freeze
  TYPE_DELAY = 0.05

  attr_reader :browser
  def initialize(browser)
    @browser = browser
  end

  def type(value)
    value.chars do |char|
      send_character(char)
      sleep(TYPE_DELAY)
    end
  end

  def send_character(char)
    # await this._client.send('Input.dispatchKeyEvent', {
    #   type: 'char',
    #   modifiers: this._modifiers,
    #   text: char,
    #   key: char,
    #   unmodifiedText: char
    # });

    browser.send_cmd("Input.dispatchKeyEvent",
                     type: :char,
                     text: char,
                     unmodifiedText: char,
                     key: char)
  end

  def key_down(_keycode)
    # async down(key, options = { text: undefined }) {
    #   const description = this._keyDescriptionForString(key);

    #   const autoRepeat = this._pressedKeys.has(description.code);
    #   this._pressedKeys.add(description.code);
    #   this._modifiers |= this._modifierBit(description.key);

    #   const text = options.text === undefined ? description.text : options.text;
    #   await this._client.send('Input.dispatchKeyEvent', {
    #     type: text ? 'keyDown' : 'rawKeyDown',
    #     modifiers: this._modifiers,
    #     windowsVirtualKeyCode: description.keyCode,
    #     code: description.code,
    #     key: description.key,
    #     text: text,
    #     unmodifiedText: text,
    #     autoRepeat,
    #     location: description.location,
    #     isKeypad: description.location === 3
    #   });
    browser.send_cmd("Input.dispatchKeyEvent", type: :text)
  end

  def key_up(keycode)
  end

  private

  def keyboard_layout
    @keyboard_layout ||= begin
                           json = File.read File.join(File.dirname(__FILE__), KEYBOARD_LAYOUT_PATH)
                           JSON.parse(json)
                         end
  end
end
