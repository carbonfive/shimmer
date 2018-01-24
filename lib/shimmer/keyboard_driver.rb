require "json"

class Capybara::Shimmer::KeyboardDriver
  class UnknownKeyError < StandardError
  end

  KEYBOARD_LAYOUT_PATH = "./data/us_keyboard_layout.json".freeze
  TYPE_DELAY = 0.00

  attr_reader :browser
  def initialize(browser)
    @browser = browser
  end

  # Only sends "input" events through the DOM.
  def type(value)
    value.to_s.chars do |char|
      send_character(char)
      sleep(TYPE_DELAY)
    end
  end

  # Sends keydown and keyup events through the DOM.
  def type_raw(value)
    value.to_s.chars do |char|
      key_down(char)
      key_up(char)
      sleep(TYPE_DELAY)
    end
  end

  def send_character(char)
    browser.send_cmd("Input.dispatchKeyEvent",
                     type: :char,
                     text: char,
                     unmodifiedText: char,
                     key: char)
  end

  def key_down(key_string)
    description = key_description_for_string(key_string)
    browser.send_cmd("Input.dispatchKeyEvent",
                     type: :keyDown,
                     windowsVirtualKeyCode: description.key_code,
                     code: description.code,
                     key: description.key,
                     text: description.text,
                     unmodifiedText: description.text,
                     location: description.location,
                     isKeypad: description.location == 3)
  end

  def key_up(key_string)
    description = key_description_for_string(key_string)
    browser.send_cmd("Input.dispatchKeyEvent",
                     type: :keyUp,
                     windowsVirtualKeyCode: description.key_code,
                     code: description.code,
                     key: description.key,
                     text: description.text,
                     unmodifiedText: description.text,
                     location: description.location,
                     isKeypad: description.location == 3)
  end

  private

  def keyboard_layout
    @keyboard_layout ||= begin
                           json = File.read File.join(File.dirname(__FILE__), KEYBOARD_LAYOUT_PATH)
                           JSON.parse(json)
                         end
  end

  def find_keyboard_definition(key_string)
    definition = keyboard_layout[key_string]
    raise UnknownKeyError, "Unknown key: #{key_string}" if definition.nil?
    OpenStruct.new(definition)
  end

  # TODO/andrewhao Need to add modifier key detection
  def key_description_for_string(key_string)
    shift = nil
    description = OpenStruct.new(
      key: "",
      keyCode: 0,
      code: "",
      text: "",
      location: 0
    )

    definition = find_keyboard_definition(key_string)

    description.key = definition.key if definition.key
    description.key_code = definition.keyCode if definition.keyCode
    description.code = definition.code if definition.code
    description.text = description.key if description.key.length == 1
    description.text = definition.text if definition.text

    description
  end
end
