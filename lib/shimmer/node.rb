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
        
      end
    end
  end
end
