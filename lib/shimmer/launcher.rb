require "socket"
require "timeout"

# Manages a Google Chrome process and calls to it through the Google Chrome DevTools API.
module Capybara
  module Shimmer
    class Launcher
      attr_reader :host, :port, :headless

      def initialize(host:, port:, headless: false)
        @host = host
        @port = port
        @headless = headless
      end

      def start
        make_directories!

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

        @browser_pid
      end

      def launcher_args
        chrome_profile_path = File.join(@tmp_dir, "puppeteer_dev_profile-")

        default_args = [
          "--disable-background-networking",
          "--disable-background-timer-throttling",
          "--disable-client-side-phishing-detection",
          "--disable-default-apps",
          "--disable-extensions",
          "--disable-hang-monitor",
          "--disable-popup-blocking",
          "--disable-prompt-on-repost",
          "--disable-sync",
          "--disable-translate",
          "--metrics-recording-only",
          "--no-first-run",
          "--safebrowsing-disable-auto-update",
          "--enable-automation",
          "--password-store=basic",
          "--use-mock-keychain",
          "--user-data-dir=#{chrome_profile_path}"
        ]

        headless_args = [
          "--headless",
          "--hide-scrollbars",
          "--mute-audio"
        ]

        default_args.append("--enable-logging=stdout") if browser_console_logging?
        default_args.concat(headless_args) if headless
        default_args.append("--remote-debugging-port=#{port}")
        default_args.append("--window-size=#{window_height},#{window_width}")
      end

      def browser_console_logging?
        true
      end

      def window_height
        1080
      end

      def window_width
        1920
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

      def make_directories!
        FileUtils.mkdir_p("log")
        @tmp_dir = Dir.mktmpdir
      end

      def kill!
        Process.kill "INT", @browser_pid
      end

      def register_shutdown_hook!
        at_exit do
          kill!
        end
      end
    end
  end
end
