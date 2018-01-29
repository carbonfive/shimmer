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
        query_fn = wrap_iife(query) { build_xpath_query }
        array_result = JavascriptBridge.global_evaluate_script(browser, query_fn, return_by_value: false)
        nodes_from_property_array(array_result)
      end

      def scoped_find_xpath(query, scope: root_node)
        query_fn = wrap_fn { build_xpath_query }
        javascript_bridge = JavascriptBridge.new(browser, devtools_remote_object_id: scope.devtools_remote_object_id)
        array_result = javascript_bridge.evaluate_js(query_fn, [
          { value: query },
          { objectId: scope.devtools_remote_object_id }
        ])
        nodes_from_property_array(array_result)
      end

      def find_css(query)
        query_fn = wrap_iife(query) { build_css_query }
        array_result = JavascriptBridge.global_evaluate_script(browser, query_fn, return_by_value: false)
        nodes_from_property_array(array_result)
      end

      def scoped_find_css(query, scope: root_node)
        query_fn = wrap_fn { build_css_query }
        javascript_bridge = JavascriptBridge.new(browser, devtools_remote_object_id: scope.devtools_remote_object_id)
        array_result = javascript_bridge.evaluate_js(query_fn, [
          { value: query },
          { objectId: scope.devtools_remote_object_id }
        ])
        nodes_from_property_array(array_result)
      end

      private

      def nodes_from_property_array(property_array)
        browser
          .send_cmd("Runtime.getProperties", objectId: property_array.objectId, ownProperties: true)
          .result
          .flatten
          .map(&:value)
          .select { |node| node.type == "object" && node.subtype == "node" }
          .map(&:objectId)
          .map do |node_object_id|
          shimmer_node_for_object_id(node_object_id)
        end
      end

      def root_node
        result = JavascriptBridge.global_evaluate_script(browser, "document", return_by_value: false)
        shimmer_node_for_object_id(result.objectId, root_node: true)
      end

      def build_xpath_query
        "
          const iterator = document.evaluate(query, element, null, XPathResult.ORDERED_NODE_ITERATOR_TYPE);
          const array = [];
          let item;
          while ((item = iterator.iterateNext()))
            array.push(item);
          return array;
        "
      end

      def wrap_fn
        "function(query, element) { #{yield} }"
      end

      def wrap_iife(query, js_context: "document")
        "(function(query, element) {
          #{yield}
        })(#{query.inspect}, #{js_context})
        "
      end

      def build_css_query
        "
          return element.querySelectorAll(query);
        "
      end

      def shimmer_node_for_object_id(node_object_id, root_node: false)
        devtools_node_props = describe_node(object_id: node_object_id)
        node_id = devtools_node_props.nodeId
        backend_node_id = devtools_node_props.backendNodeId
        html_fragment = browser.html_for(backend_node_id: backend_node_id)
        nokogiri_element = nokogiri_htmlize(html_fragment, fragment: !root_node)
        Capybara::Shimmer::Node.new(self,
                                    nokogiri_element,
                                    devtools_node_id: node_id,
                                    devtools_backend_node_id: backend_node_id,
                                    devtools_remote_object_id: node_object_id)
      end

      def describe_node(node_id: nil, object_id: nil)
        if node_id
          browser.send_cmd("DOM.describeNode", nodeId: node_id).node
        elsif object_id
          browser.send_cmd("DOM.describeNode", objectId: object_id).node
        end
      end

      def nokogiri_htmlize(html_string, fragment: true)
        if fragment
          Nokogiri::HTML.fragment(html_string).children.first
        else
          Nokogiri::HTML(html_string).children.first
        end
      end
    end
  end
end
