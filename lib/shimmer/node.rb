# A representation of a single DOM node
#
# A DOMNode type in DevTools Protocol follows this schema:
#
# {"node"=>
#   {"nodeId"=>0,
#    "backendNodeId"=>26,
#    "nodeType"=>1,
#    "nodeName"=>"LI",
#    "localName"=>"li",
#    "nodeValue"=>"",
#    "childNodeCount"=>1,
#    "attributes"=>["class", "css-resources"]}}
#
module Capybara
  module Shimmer
    class Node < Capybara::Driver::Node
      attr_reader :driver, :native

      def initialize(driver, native)
        super(driver, native)
        @driver = driver
        @native = native
      end

      def all_text
        raise NotImplementedError
      end

      def visible_text
        attrs.nodeValue
      end

      def [](name)
        attributes = Hash[*attrs.attributes].symbolize_keys
        attributes[name]
      end

      def value
        self[:value]
      end

      # @param value String or Array. Array is only allowed if node has 'multiple' attribute
      # @param options [Hash{}] Driver specific options for how to set a value on a node
      def set(value, **options)
        raise NotImplementedError
      end

      def select_option
        raise NotImplementedError
      end

      def unselect_option
        raise NotImplementedError
      end

      def click(keys = [], options = {})
        raise NotImplementedError
      end

      def right_click(keys = [], options = {})
        raise NotImplementedError
      end

      def double_click(keys = [], options = {})
        raise NotImplementedError
      end

      def send_keys(*args)
        raise NotImplementedError
      end

      def hover
        raise NotImplementedError
      end

      def drag_to(element)
        raise NotImplementedError
      end

      def tag_name
      end

      def visible?
        # TODO implement actual
        true
      end

      def checked?
        raise NotImplementedError
      end

      def selected?
        raise NotImplementedError
      end

      def disabled?
        raise NotImplementedError
      end

      def readonly?
        !!self[:readonly]
      end

      def multiple?
        !!self[:multiple]
      end

      def path
        raise NotSupportedByDriverError, 'Capybara::Driver::Node#path'
      end

      def trigger(event)
        raise NotSupportedByDriverError, 'Capybara::Driver::Node#trigger'
      end

      def inspect
        %(#<#{self.class} tag="#{tag_name}" path="#{path}">)
      rescue NotSupportedByDriverError
        %(#<#{self.class} tag="#{tag_name}">)
      end

      def ==(other)
        raise NotSupportedByDriverError, 'Capybara::Driver::Node#=='
      end

      private

      def attrs
        native["node"]
      end
    end
  end
end
