require "socket"
require "timeout"

module Capybara
  module Shimmer
    class Browser
      DEVTOOLS_PORT = 9222
      DEVTOOLS_PROXY_PORT = 9223
      DEVTOOLS_HOST = "localhost"

      attr_accessor :browser_pid, :port, :host, :headless

      def initialize(port: DEVTOOLS_PORT, host: DEVTOOLS_HOST, use_proxy: false, headless: false)
        @port = port
        @host = host
        @use_proxy = use_proxy
        @headless = headless
      end

      def start
        headless_flag = headless ? " --headless" : ""
        @browser_pid = Process.spawn "'/Applications/Google Chrome.app/Contents/MacOS/Google Chrome' --remote-debugging-port=#{port}#{headless_flag}"
        puts "Booting up Chrome browser with remote debugging port at #{@browser_pid}..."
        register_shutdown_hook

        until is_port_open?(host, port)
          sleep 1
          puts "."
        end

        client = ChromeRemote.client host: host,
                                     port: @use_proxy ? DEVTOOLS_PROXY_PORT : port
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
        client.send_cmd "DOM.enable"
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
