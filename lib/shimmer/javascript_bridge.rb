# Evaluates a JS function on the provided remote node
module Capybara
  module Shimmer
    class JavascriptBridge
      attr_reader :browser, :devtools_remote_object_id

      def initialize(browser, devtools_remote_object_id:)
        @browser = browser
        @devtools_remote_object_id = devtools_remote_object_id
      end

      # Node is bound to Javascript `this`
      def evaluate_js(js_fn, args=[])
        result = browser.send_cmd("Runtime.callFunctionOn",
                                  functionDeclaration: js_fn,
                                  objectId: devtools_remote_object_id,
                                  awaitPromise: true,
                                  arguments: args,
                                  userGesture: true,
                                  returnByValue: false)
        if result.exceptionDetails
          raise JavascriptEvaluationError, result.exceptionDetails.exception
        elsif !result.result.value.nil?
          result.result.value
        else
          result.result
        end
      end

      def self.global_evaluate_script(browser, script, return_by_value: true)
        returned = browser.send_cmd("Runtime.evaluate", expression: script, returnByValue: return_by_value, awaitPromise: true)
        raise JavascriptEvaluationError, returned.exceptionDetails.exception if returned.exceptionDetails
        if return_by_value
          returned.result.value
        else
          returned.result
        end
      end
    end
  end
end
