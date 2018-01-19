# Encompasses finder methods to navigate the DOM, returning Nodes
module Capybara
  module Shimmer
    class Finder
      extend Forwardable

      attr_reader :driver

      def initialize(driver)
        @driver = driver
      end

      def find_xpath(query)
        query_fn = "
        (function(expression, element) {
          const iterator = document.evaluate(expression, element, null, XPathResult.ORDERED_NODE_ITERATOR_TYPE);
          const array = [];
          let item;
          while ((item = iterator.iterateNext()))
            array.push(item);
          return array;
        })(#{query.inspect}, document)
        "
        array_result = driver.evaluate_script(query_fn, return_by_value: false)
        browser
          .send_cmd("Runtime.getProperties", objectId: array_result.objectId, ownProperties: true)
          .result
          .flatten
          .map(&:value)
          .select { |node| node.type == "object" && node.subtype == "node" }
          .map(&:objectId)
          .map do |nodeObjectId|
          devtools_node_props = browser.send_cmd("DOM.describeNode", objectId: nodeObjectId).node
          node_id = devtools_node_props.nodeId
          backend_node_id = devtools_node_props.backendNodeId
          html_fragment = browser.html_for(backend_node_id: backend_node_id)
          nokogiri_element = nokogiri_htmlize(html_fragment)
          Capybara::Shimmer::Node.new(self, nokogiri_element, devtools_node_id: node_id, devtools_backend_node_id: backend_node_id)
        end
      end

      def find_xpath_with_nokogiri(query)
        Nokogiri::HTML(html)
          .xpath(query)
          .map do |node|
          Capybara::Shimmer::Node.new(self, node)
        end
      end

      def find_css_with_nokogiri(query)
        Nokogiri::HTML(html)
          .css(query)
          .map do |node|
          Capybara::Shimmer::Node.new(self, node)
        end
      end

      def find_css(query)
        root_node_id = browser.root_node_id
        results = browser.send_cmd(
          "DOM.querySelectorAll",
          selector: query, nodeId: root_node_id
        ).nodeIds.map do |node_id|
          html_fragment = browser.html_for(node_id: node_id)
          devtools_node_props = browser.send_cmd("DOM.describeNode", nodeId: node_id).node
          nokogiri_element = nokogiri_htmlize(html_fragment)
          Capybara::Shimmer::Node.new(self, nokogiri_element, devtools_node_id: node_id, devtools_backend_node_id: devtools_node_props.backendNodeId)
        end
      end

      private

      def devtools_raw_node(node_id:)
        browser.send_cmd("DOM.describeNode", nodeId: node_id).node
      end

      def nokogiri_htmlize(html_string)
        Nokogiri::HTML.fragment(html_string).children.first
      end

      def_delegators :driver, :browser
    end
  end
end
