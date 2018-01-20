# A representation of a single DOM node
#
# Our current implementation depends on Ruby-land Nokogiri parsing.
#
# This will suffice for simple read operations, but will start to break down
# when testing for visibility and DOM-mutating operations.
module Capybara
  module Shimmer
    class Node < Capybara::RackTest::Node
      MOUSE_MOVE_DELAY = 0.25
      MOUSE_CLICK_DELAY = 0.25

      attr_reader :devtools_node_id, :devtools_backend_node_id

      def initialize(driver, native, devtools_node_id: nil, devtools_backend_node_id: nil)
        super(driver, native)
        @devtools_node_id = devtools_node_id
        @devtools_backend_node_id = devtools_backend_node_id
        if devtools_node_id.nil?

        end
      end

      def click
        browser.send_cmd("Input.dispatchMouseEvent",
                         x: center_coordinates.x,
                         y: center_coordinates.y,
                         type: "mouseMoved")
        sleep(MOUSE_MOVE_DELAY)
        browser.send_cmd("Input.dispatchMouseEvent",
                         x: center_coordinates.x,
                         y: center_coordinates.y,
                         button: "left",
                         clickCount: 1,
                         type: "mousePressed")
        sleep(MOUSE_CLICK_DELAY)
        browser.send_cmd("Input.dispatchMouseEvent",
                         x: center_coordinates.x,
                         y: center_coordinates.y,
                         button: "left",
                         clickCount: 1,
                         type: "mouseReleased")
      end

      private

      def bounding_box
        quad = box_model.border
        x = [quad[0], quad[2], quad[4], quad[6]].min
        y = [quad[1], quad[3], quad[5], quad[7]].min
        width = [quad[0], quad[2], quad[4], quad[6]].max - x
        height = [quad[1], quad[3], quad[5], quad[7]].max - y

        OpenStruct.new(x: x, y: y, width: width, height: height)
      end

      def box_model
        @box_model ||= browser.send_cmd("DOM.getBoxModel", backendNodeId: devtools_backend_node_id).model
      end

      def center_coordinates
        x = bounding_box.x + (bounding_box.width / 2)
        y = bounding_box.y + (bounding_box.height / 2)
        OpenStruct.new(x: x, y: y)
      end

      def browser
        driver.browser
      end
    end
  end
end
