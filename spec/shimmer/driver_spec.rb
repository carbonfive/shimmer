require "spec_helper"

RSpec.describe Capybara::Shimmer::Driver do
  let(:app) { double("app") }
  let(:browser) { instance_double(Capybara::Shimmer::Browser) }
  let(:options) { { browser: browser } }
  subject { described_class.new(app, options) }

  describe "#current_url" do
    it "delegates to the browser" do
      expect(browser).to receive(:current_url)
      subject.current_url
    end
  end

  describe "#evaluate_script" do
    context "return_by_value true" do
      it "calls Runtime.evaluate with expression" do
        expect(browser).to receive(:send_cmd)
          .with("Runtime.evaluate", expression: "1+1", returnByValue: true, awaitPromise: true)
          .and_return(double(result: double(type: "number", value: 2), exceptionDetails: nil))
        result = subject.evaluate_script("1+1")
        expect(result).to eq 2
      end

      it "raises error message exception for bad expression" do
        expect(browser).to receive(:send_cmd)
          .with("Runtime.evaluate", expression: "badcmd", returnByValue: true, awaitPromise: true) do
          double(
            result: double(type: "object", subtype: "error"),
            exceptionDetails: double(
              exception: double(
                className: "SyntaxError",
                description: "description"
              )
            )
          )
        end
        expect {
          subject.evaluate_script("badcmd")
        }.to raise_error(Capybara::Shimmer::JavascriptEvaluationError)
      end
    end
  end

  describe "#execute_script" do
    it "calls Runtime.evaluate with expression" do
      expect(browser).to receive(:send_cmd)
        .with("Runtime.evaluate", expression: "1+1", returnByValue: false, awaitPromise: true)
        .and_return(double(result: double(type: "number", value: 2), exceptionDetails: nil))
      result = subject.execute_script("1+1")
    end

    it "raises error message exception for bad expression" do
      expect(browser).to receive(:send_cmd)
        .with("Runtime.evaluate", expression: "badcmd", returnByValue: false, awaitPromise: true) do
        double(
          result: double(type: "object", subtype: "error"),
          exceptionDetails: double(
            exception: double(
              className: "SyntaxError",
              description: "description"
            )
          )
        )
      end
      expect {
        subject.execute_script("badcmd")
      }.to raise_error(Capybara::Shimmer::JavascriptEvaluationError)
    end
  end
end
