# Encompasses finder methods to navigate the DOM, returning Nodes
module Capybara
  module Shimmer
    class Finder
      extend Forwardable

      attr_reader :browser

      def initialize(browser)
        @browser = browser
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
        array_result = JavascriptBridge.global_evaluate_script(browser, query_fn, return_by_value: false)
        browser
          .send_cmd("Runtime.getProperties", objectId: array_result.objectId, ownProperties: true)
          .result
          .flatten
          .map(&:value)
          .select { |node| node.type == "object" && node.subtype == "node" }
          .map(&:objectId)
          .map do |node_object_id|
          devtools_node_props = describe_node(object_id: node_object_id)
          node_id = devtools_node_props.nodeId
          backend_node_id = devtools_node_props.backendNodeId
          html_fragment = browser.html_for(backend_node_id: backend_node_id)
          nokogiri_element = nokogiri_htmlize(html_fragment)
          Capybara::Shimmer::Node.new(self,
                                      nokogiri_element,
                                      devtools_node_id: node_id,
                                      devtools_backend_node_id: backend_node_id,
                                      devtools_remote_object_id: node_object_id)
        end
      end

      def find_css(query)
        query_fn = "
        (function(selector, element) {
          return element.querySelectorAll(selector);
        })(#{query.inspect}, document)
        "
        array_result = JavascriptBridge.global_evaluate_script(browser, query_fn, return_by_value: false)
        browser
          .send_cmd("Runtime.getProperties", objectId: array_result.objectId, ownProperties: true)
          .result
          .flatten
          .map(&:value)
          .select { |node| node.type == "object" && node.subtype == "node" }
          .map(&:objectId)
          .map do |node_object_id|

          devtools_node_props = describe_node(object_id: node_object_id)
          node_id = devtools_node_props.nodeId
          backend_node_id = devtools_node_props.backendNodeId
          html_fragment = browser.html_for(backend_node_id: backend_node_id)
          nokogiri_element = nokogiri_htmlize(html_fragment)
          Capybara::Shimmer::Node.new(self,
                                      nokogiri_element,
                                      devtools_node_id: node_id,
                                      devtools_backend_node_id: backend_node_id,
                                      devtools_remote_object_id: node_object_id)
        end
      end

      private

      def describe_node(node_id: nil, object_id: nil)
        if node_id
          browser.send_cmd("DOM.describeNode", nodeId: node_id).node
        elsif object_id
          browser.send_cmd("DOM.describeNode", objectId: object_id).node
        end
      end

      def nokogiri_htmlize(html_string)
        Nokogiri::HTML.fragment(html_string).children.first
      end
    end
  end
end
