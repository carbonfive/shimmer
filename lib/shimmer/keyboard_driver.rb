require "json"

module Capybara
  module Shimmer
    class KeyboardDriver
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
        named_key = convert_to_named_keys(key_string)
        definition = if named_key.is_a?(String)
                       keyboard_layout[named_key]
                     else
                       keyboard_layout[named_key["key"]]
                     end
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

      def convert_to_named_keys(key)
        case key
        when :cancel, :help, :backspace, :tab, :clear, :return, :enter, :insert, :delete, :pause, :escape,
             :space, :end, :home, :left, :up, :right, :down, :semicolon,
             :f1, :f2, :f3, :f4, :f5, :f6, :f7, :f8, :f9, :f10, :f11, :f12,
             :shift, :control, :alt, :meta
          { "key" => key.to_s.capitalize }
        when :equals
          { "key" => "Equal" }
        when :page_up
          { "key" => "PageUp" }
        when :page_down
          { "key" => "PageDown" }
        when :numpad0, :numpad1, :numpad2, :numpad3, :numpad4,
             :numpad5, :numpad6, :numpad7, :numpad9, :numpad9
          { "key" => key[-1], "modifier" => "keypad" }
        when :multiply
          { "key" => "Asterisk", "modifier" => "keypad" }
        when :divide
          { "key" => "Slash", "modifier" => "keypad" }
        when :add
          { "key" => "Plus", "modifier" => "keypad" }
        when :subtract
          { "key" => "Minus", "modifier" => "keypad" }
        when :decimal
          { "key" => "Period", "modifier" => "keypad" }
        when :command
          { "key" => "Meta" }
        when String
          key.to_s
        else
          raise Capybara::NotSupportedByDriverError
        end
      end
    end
  end
end
