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
                     devtools_node_id:,
                     devtools_backend_node_id:,
                     devtools_remote_object_id:)
        super(driver, native)
        @devtools_node_id = devtools_node_id
        @devtools_backend_node_id = devtools_backend_node_id
        @devtools_remote_object_id = devtools_remote_object_id
      end

      def value
        javascript_bridge.evaluate_js("function() { return this.value }")
      end

      def click
        scroll_into_view_if_needed!
        mouse_driver.click(self)

        # TODO/andrewhao
        # Assumption: the browser needs to "work" after you click a link
        # Therefore: we must block the test runner from taking action on any expectations
        # before the browser has transitioned.
        # Outcome: more reliable specs.
        #
        # (Problematic assumption - what if the click merely re-renders a node
        # on the DOM like an accordion?)
        # browser.wait_for("Page.frameStoppedLoading")
      end

      def set(value)
        scroll_into_view_if_needed!
        javascript_bridge.evaluate_js("function() { this.value = '#{value}'; }")
      end

      def send_keys(value)
        scroll_into_view_if_needed!
        select!
        keyboard_driver.type(value)
      end

      def focus!
        javascript_bridge.evaluate_js("function() { return this.focus() }")
      end

      def select!
        javascript_bridge.evaluate_js("function() { return this.select() }")
      end

      def hover
        scroll_into_view_if_needed!
        mouse_driver.move_to(self)
      end

      def center_coordinates
        x = bounding_box.x + (bounding_box.width / 2)
        y = bounding_box.y + (bounding_box.height / 2)
        OpenStruct.new(x: x, y: y)
      end

      def select_option
        javascript_bridge.evaluate_js("
          function() {
            this.dispatchEvent(new Event('input', { 'bubbles': true }));
            this.dispatchEvent(new Event('change', { 'bubbles': true }));
            this.selected = true;
          }
        ")
      end

      def html
        javascript_bridge.evaluate_js("function() { return this.innerHTML }")
      end

      def find_css(query)
        Capybara::Shimmer::Finder.new(browser).scoped_find_css(query, scope: self)
      end

      def find_xpath(query)
        Capybara::Shimmer::Finder.new(browser).scoped_find_xpath(query, scope: self)
      end

      private

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

      def scroll_into_view_if_needed!
        javascript_bridge.evaluate_js("function() { return this.scrollIntoViewIfNeeded() }")
      end

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
