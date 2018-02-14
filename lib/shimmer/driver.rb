require "capybara"
require "chrome_remote"
require "shimmer/browser"

module Capybara
  module Shimmer
    class Driver < Capybara::Driver::Base
      attr_reader :browser, :options, :logger
      extend Forwardable

      def initialize(app, options = {})
        supplied_browser = options.delete(:browser)
        @logger  = Logger.new(STDOUT)
        @options = options.dup
        @browser = supplied_browser || Capybara::Shimmer::Browser.new(@options).start
        @app     = app
      end

      def_delegators :browser, :current_url, :visit, :html,
                     :evaluate_script, :execute_script, :save_screenshot, :reset!,
                     :dismiss_modal, :accept_modal

      def refresh
        raise NotImplementedError
      end

      def_delegators :finder, :find_xpath, :find_css

      def go_back
        raise Capybara::NotSupportedByDriverError, "Capybara::Driver::Base#go_back"
      end

      def go_forward
        raise Capybara::NotSupportedByDriverError, "Capybara::Driver::Base#go_forward"
      end

      def evaluate_async_script(_script, *_args)
        raise Capybara::NotSupportedByDriverError, "Capybara::Driver::Base#evaluate_script_asnyc"
      end

      def response_headers
        raise Capybara::NotSupportedByDriverError, "Capybara::Driver::Base#response_headers"
      end

      def status_code
        raise Capybara::NotSupportedByDriverError, "Capybara::Driver::Base#status_code"
      end

      ##
      #
      # @param frame [Capybara::Node::Element, :parent, :top]  The iframe element to switch to
      #
      def switch_to_frame(_frame)
        raise Capybara::NotSupportedByDriverError, "Capybara::Driver::Base#switch_to_frame"
      end

      def current_window_handle
        raise Capybara::NotSupportedByDriverError, "Capybara::Driver::Base#current_window_handle"
      end

      def window_size(_handle)
        raise Capybara::NotSupportedByDriverError, "Capybara::Driver::Base#window_size"
      end

      def resize_window_to(_handle, _width, _height)
        raise Capybara::NotSupportedByDriverError, "Capybara::Driver::Base#resize_window_to"
      end

      def maximize_window(_handle)
        raise Capybara::NotSupportedByDriverError, "Capybara::Driver::Base#maximize_current_window"
      end

      def close_window(_handle)
        raise Capybara::NotSupportedByDriverError, "Capybara::Driver::Base#close_window"
      end

      def window_handles
        raise Capybara::NotSupportedByDriverError, "Capybara::Driver::Base#window_handles"
      end

      def open_new_window
        raise Capybara::NotSupportedByDriverError, "Capybara::Driver::Base#open_new_window"
      end

      def switch_to_window(_handle)
        raise Capybara::NotSupportedByDriverError, "Capybara::Driver::Base#switch_to_window"
      end

      def no_such_window_error
        raise Capybara::NotSupportedByDriverError, "Capybara::Driver::Base#no_such_window_error"
      end

      def invalid_element_errors
        []
      end

      def wait?
        true
      end

      def needs_server?
        true
      end

      def session_options
      end

      private

      def finder
        @finder ||= Finder.new(browser)
      end

      # rubocop:enable Lint/UnusedMethodArgument
    end
  end
end
