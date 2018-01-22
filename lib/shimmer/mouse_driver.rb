module Capybara
  module Shimmer
    class MouseDriver
      attr_reader :browser
      MOUSE_MOVE_DELAY = 0.25
      MOUSE_CLICK_DELAY = 0.25


      def initialize(browser)
        @browser = browser
      end

      def click(node)
        browser.send_cmd("Input.dispatchMouseEvent",
                         x: node.center_coordinates.x,
                         y: node.center_coordinates.y,
                         type: "mouseMoved")
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
    end
  end
end
