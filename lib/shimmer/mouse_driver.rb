module Capybara
  module Shimmer
    class MouseDriver
      MOUSE_MOVE_DELAY = 0.25
      MOUSE_CLICK_DELAY = 0.25

      attr_reader :browser

      def initialize(browser)
        @browser = browser
      end

      def click(node)
        move_to(node)
        sleep(MOUSE_MOVE_DELAY)
        browser.send_cmd("Input.dispatchMouseEvent",
                         x: node.center_coordinates.x,
                         y: node.center_coordinates.y,
                         button: "left",
                         clickCount: 1,
                         type: "mousePressed")
        sleep(MOUSE_CLICK_DELAY)
        browser.send_cmd("Input.dispatchMouseEvent",
                         x: node.center_coordinates.x,
                         y: node.center_coordinates.y,
                         button: "left",
                         clickCount: 1,
                         type: "mouseReleased")
      end

      def move_to(node)
        browser.send_cmd("Input.dispatchMouseEvent",
                         x: node.center_coordinates.x,
                         y: node.center_coordinates.y,
                         type: "mouseMoved")
      end
    end
  end
end
