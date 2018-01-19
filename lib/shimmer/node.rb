# A representation of a single DOM node
#
# Our current implementation depends on Ruby-land Nokogiri parsing.
#
# This will suffice for simple read operations, but will start to break down
# when testing for visibility and DOM-mutating operations.
module Capybara
  module Shimmer
    class Node < Capybara::RackTest::Node
      def click
        binding.pry
        browser.send_cmd('')
      end

      private

      def scroll_into_view_if_needed
      end

      def bounding_box
        browser.send_cmd('')
      end

      def center_coordinates
      end

      def browser
        driver.browser
      end

      def devtools_node_id
      end

      def devtools_backend_node_id
      end
    end
  end
end
