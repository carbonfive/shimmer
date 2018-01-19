# Manages a Google Chrome process and calls to it through the Google Chrome
# DevTools API.
module Capybara
  module Shimmer
    class Browser
      extend Forwardable

      DEVTOOLS_PORT = 9222
      DEVTOOLS_PROXY_PORT = 9223
      DEVTOOLS_HOST = "localhost"

      attr_reader :browser_pid, :port, :host, :client
      def_delegators :client, :wait_for, :send_cmd, :wait_for_with_either_match

      def initialize(port: DEVTOOLS_PORT, host: DEVTOOLS_HOST, use_proxy: false, headless: false, client: nil)
        @port = port
        @host = host
        @headless = headless
        @use_proxy = use_proxy
        @client = client
      end

      def start
        Launcher.new(host: @host, port: @port, headless: @headless).start
        setup_client!
        self
      end

      def visit(path)
        client.send_cmd "Page.navigate", url: path
        client.wait_for_with_either_match("Page.lifecycleEvent",
                                          match: { "name" => "load" },
                                          match2: { "name" => "networkIdle" })
      end

      def reset!
        client.send_cmd("Page.navigate", url: "about:blank")
        client.send_cmd("Network.clearBrowserCookies")
      end

      def current_url
        client.send_cmd("Runtime.evaluate", expression: "window.location.href")
          .result
          .value
      end

      private

      def setup_client!
        @client = ChromeRemote.client host: host,
                                      port: @use_proxy ? DEVTOOLS_PROXY_PORT : port
        @client.send_cmd "Network.enable"
        @client.send_cmd "Page.enable"
        @client.send_cmd "DOM.enable"

        @client
      end
    end
  end
end
