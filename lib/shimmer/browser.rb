require "socket"
require "timeout"

# Manages a Google Chrome process and calls to it through the Google Chrome
# DevTools API.
module Capybara
  module Shimmer
    class Browser
      extend Forwardable

      DEVTOOLS_PORT = 9222
      DEVTOOLS_PROXY_PORT = 9223
      DEVTOOLS_HOST = "localhost"

      attr_accessor :browser_pid, :port, :host, :headless, :client
      def_delegators :client, :wait_for, :send_cmd, :wait_for_with_either_match

      def initialize(port: DEVTOOLS_PORT, host: DEVTOOLS_HOST, use_proxy: false, headless: false)
        @port = port
        @host = host
        @use_proxy = use_proxy
        @headless = headless
        @client = nil
      end

      def start
        process_command = "'/Applications/Google Chrome.app/Contents/MacOS/Google Chrome' #{launcher_args.join(" ")}"
        @browser_pid = Process.spawn process_command, %i[out err] => "log/chrome.#{Time.now.to_f}.log"
        puts
        puts process_command
        puts "Booting up Chrome browser with PID #{@browser_pid}..."
        register_shutdown_hook!

        until is_port_open?(host, port)
          sleep 1
          puts "."
        end

        setup_client!
        self
      end

      def reset!
        client.send_cmd("Page.navigate", url: "about:blank")
        client.send_cmd("Network.clearBrowserCookies")
      end

      private

      def kill!
        Process.kill "INT", @browser_pid
      end

      def register_shutdown_hook!
        at_exit do
          kill!
        end
      end

      def setup_client!
        @client = ChromeRemote.client host: host,
                                      port: @use_proxy ? DEVTOOLS_PROXY_PORT : port
        @client.send_cmd "Network.enable"
        @client.send_cmd "Page.enable"
        @client.send_cmd "DOM.enable"

        @client
      end

      def is_port_open?(ip, port)
        begin
          Timeout.timeout(4) do
            begin
              s = TCPSocket.new(ip, port)
              s.close
              return true
            rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
              return false
            end
          end
        rescue Timeout::Error
        end

        false
      end

      def launcher_args
        # As great as these defaults are, they cause headed shimmer to run
        # INCREDIBLY slow. We can re-enable these as needed in the future.
        #
        # These are default args provided by the puppeteer project.
        #
        # default_args = ["--disable-background-networking",
        #                 "--disable-background-timer-throttling",
        #                 "--disable-client-side-phishing-detection",
        #                 "--disable-default-apps",
        #                 "--disable-extensions",
        #                 "--disable-hang-monitor",
        #                 "--disable-popup-blocking",
        #                 "--disable-prompt-on-repost",
        #                 "--disable-sync",
        #                 "--disable-translate",
        #                 "--metrics-recording-only",
        #                 "--no-first-run",
        #                 "--safebrowsing-disable-auto-update",
        #                 "--enable-automation",
        #                 "--password-store=basic",
        #                 "--use-mock-keychain"]

        default_args = [
          "--enable-automation"
        ]

        headless_args = [
          "--headless",
          "--disable-gpu",
          "--hide-scrollbars",
          "--mute-audio"
        ]

        default_args.append("--enable-logging=stdout") if browser_console_logging?
        default_args.concat(headless_args) if headless
        default_args.append("--remote-debugging-port=#{port}")
      end

      def browser_console_logging?
        true
      end
    end
  end
end
