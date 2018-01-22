# A representation of a single DOM node
#
# Our current implementation depends on Ruby-land Nokogiri parsing.
#
# This will suffice for simple read operations, but will start to break down
# when testing for visibility and DOM-mutating operations.
module Capybara
  module Shimmer
    class Node < Capybara::RackTest::Node
      attr_reader :devtools_node_id, :devtools_backend_node_id, :devtools_remote_object_id

      def initialize(driver,
                     native,
                     devtools_node_id: nil,
                     devtools_backend_node_id: nil,
                     devtools_remote_object_id: nil)
        super(driver, native)
        @devtools_node_id = devtools_node_id
        @devtools_backend_node_id = devtools_backend_node_id
        @devtools_remote_object_id = devtools_remote_object_id
        if devtools_node_id.nil?

        end
      end

      def value
        javascript_bridge.evaluate_js('function() { return this.value }')
      end

      def click
        mouse_driver.click(self)
      end

      def set(value)
        # return if disabled?
        # if readonly?
        #   warn "Attempt to set readonly element with value: #{value} \n * This will raise an exception in a future version of Capybara"
        #   return
        # end

        # if (Array === value) && !multiple?
        #   raise TypeError.new "Value cannot be an Array when 'multiple' attribute is not present. Not a #{value.class}"
        # end

        # if radio?
        #   set_radio(value)
        # elsif checkbox?
        #   set_checkbox(value)
        # elsif input_field?
        #   set_input(value)
        # elsif textarea?
        #   native['_capybara_raw_value'] = value.to_s
        # end

        focus!
        select!
        keyboard_driver.type(value)
      end

      def focus!
        javascript_bridge.evaluate_js('function() { return this.focus() }')
      end

      def select!
        javascript_bridge.evaluate_js('function() { return this.select() }')
      end

      def box_model
        @box_model ||= browser.send_cmd("DOM.getBoxModel", backendNodeId: devtools_backend_node_id).model
      end

      def bounding_box
        quad = box_model.border
        x = [quad[0], quad[2], quad[4], quad[6]].min
        y = [quad[1], quad[3], quad[5], quad[7]].min
        width = [quad[0], quad[2], quad[4], quad[6]].max - x
        height = [quad[1], quad[3], quad[5], quad[7]].max - y

        OpenStruct.new(x: x, y: y, width: width, height: height)
      end

      def center_coordinates
        x = bounding_box.x + (bounding_box.width / 2)
        y = bounding_box.y + (bounding_box.height / 2)
        OpenStruct.new(x: x, y: y)
      end

      private

      def javascript_bridge
        @javascript_bridge ||= JavascriptBridge.new(browser, devtools_remote_object_id: devtools_remote_object_id)
      end

      def mouse_driver
        @mouse_driver ||= MouseDriver.new(browser)
      end

      def keyboard_driver
        @keyboard_driver ||= KeyboardDriver.new(browser)
      end

      def browser
        driver.browser
      end
    end
  end
end
