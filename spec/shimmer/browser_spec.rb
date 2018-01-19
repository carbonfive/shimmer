require "spec_helper"

RSpec.describe Capybara::Shimmer::Browser do
  let(:options) { { client: client } }
  let(:client) { double("devtools_client") }

  subject { described_class.new(options) }

  describe "#current_url" do
    it "returns the current URL" do
      expect(client).to receive(:send_cmd)
        .with("Runtime.evaluate", expression: "window.location.href")
        .and_return(double(result: double(value: "the-url")))
      expect(subject.current_url).to eq "the-url"
    end
  end
end
