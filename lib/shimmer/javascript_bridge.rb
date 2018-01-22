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
                                  returnByValue: false)
        if result.exceptionDetails
          raise JavascriptEvaluationError, result.exceptionDetails.exception
        else
          result.result.value
        end
      end
    end
  end
end
