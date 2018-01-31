# Manages a Google Chrome process and calls to it through the Google Chrome
# DevTools API.
module Capybara
  module Shimmer
    class Browser
      extend Forwardable

      DEVTOOLS_PORT = 9222
      DEVTOOLS_PROXY_PORT = 9223
      DEVTOOLS_HOST = "127.0.0.1"
      DEFAULT_WINDOW_WIDTH = 1920
      DEFAULT_WINDOW_HEIGHT = 1080

      attr_reader :browser_pid, :port, :host, :client
      def_delegators :client, :wait_for, :send_cmd, :wait_for_with_either_match, :on

      # rubocop:disable Metrics/ParameterLists
      def initialize(port: DEVTOOLS_PORT,
                     host: DEVTOOLS_HOST,
                     use_proxy: false,
                     headless: false,
                     window_width: DEFAULT_WINDOW_WIDTH,
                     window_height: DEFAULT_WINDOW_HEIGHT,
                     client: nil)
        @port = port
        @host = host
        @window_width = window_width
        @window_height = window_height
        @headless = headless
        @use_proxy = use_proxy
        @client = client
      end
      # rubocop:enable Metrics/ParameterLists

      def start
        Launcher.new(
          host: @host,
          port: @port,
          headless: @headless,
          window_width: @window_width,
          window_height: @window_height
        ).start
        setup_devtools_client!
        self
      end

      def visit(path)
        client.send_cmd "Page.navigate", url: path
        client.wait_for do |event_name, event_params|
          (event_name == "Page.loadEventFired") ||
            (event_name == "Page.lifecycleEvent" &&
              (event_params["name"] == "load" ||
                event_params["name"] == "networkIdle"))
        end
      end

      def reset!
        visit("about:blank")
        client.send_cmd("Network.clearBrowserCookies")
      end

      def current_url
        client.send_cmd("Runtime.evaluate",
                        expression: "window.location.href")
          .result
          .value
      end

      def accept_modal(_type, **_options)
        yield if block_given?
        client.send_cmd("Page.handleJavaScriptDialog", accept: true)
      end

      def dismiss_modal(_type, **_options)
        yield if block_given?
        client.send_cmd("Page.handleJavaScriptDialog", accept: false)
      end

      def html
        html_for(backend_node_id: root_node.backendNodeId)
      end

      # TODO/andrewhao What should happen on errors?
      def execute_script(script, return_by_value: false)
        JavascriptBridge.global_evaluate_script(self, script, return_by_value: return_by_value)
        nil
      end

      def evaluate_script(script, return_by_value: true)
        JavascriptBridge.global_evaluate_script(self, script, return_by_value: return_by_value)
      end

      def save_screenshot(path, **_options)
        result = client.send_cmd("Page.captureScreenshot")
        File.open(path, "wb") do |file|
          file.write Base64.decode64(result.data)
        end
      end

      def html_for(backend_node_id: nil, node_id: nil)
        options = if backend_node_id
                    { backendNodeId: backend_node_id }
                  else
                    { nodeId: node_id }
                  end

        client
          .send_cmd("DOM.getOuterHTML", **options)
          .outerHTML
      end

      private

      def root_node
        client
          .send_cmd("DOM.getDocument")
          .root
      end

      def setup_devtools_client!
        @client = ChromeRemote.client host: host,
                                      port: @use_proxy ? DEVTOOLS_PROXY_PORT : port
        @client.send_cmd "Network.enable"
        @client.send_cmd "Page.enable"
        @client.send_cmd "DOM.enable"

        # Automatically dismiss all dialogs
        # TODO: This may need to be configurable, or activated on
        # a test-by-test case basis
        @client.on "Page.javascriptDialogOpening" do |params|
          accept_modal(params["type"].to_sym)
        end

        @client
      end
    end
  end
end
