require "singleton"
require "socket"
require "timeout"

module Capybara
  module Shimmer
    class Browser
      include Singleton

      DEVTOOLS_PORT = 9222
      DEVTOOLS_PROXY_PORT = 9223
      DEVTOOLS_HOST = "localhost"

      attr_accessor :browser_pid

      def start
        @browser_pid = Process.spawn "'/Applications/Google Chrome.app/Contents/MacOS/Google Chrome' --remote-debugging-port=#{DEVTOOLS_PORT}"
        puts "Booting up Chrome browser with remote debugging port at #{@browser_pid}..."
        register_shutdown_hook

        until is_port_open?(DEVTOOLS_HOST, DEVTOOLS_PORT)
          sleep 1
          puts "."
        end

        client = ChromeRemote.client host: DEVTOOLS_HOST,
                                     port: DEVTOOLS_PROXY_PORT
        setup_client(client)
      end

      def kill!
        Process.kill "INT", @browser_pid
      end

      def register_shutdown_hook
        at_exit do
          puts "Shutting down!"
          kill!
        end
      end

      def setup_client(client)
        client.send_cmd "Network.enable"
        client.send_cmd "Page.enable"
        client.on "Network.requestWillBeSent" do |params|
          puts params["request"]["url"]
        end
        client
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
    end
  end
end
