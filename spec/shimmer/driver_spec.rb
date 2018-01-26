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

  describe "#accept_modal" do
    it "sends a Page.handleJavaScriptDialog" do
      expect(browser).to receive(:send_cmd)
        .with("Page.handleJavaScriptDialog",
              accept: true)
      subject.accept_modal(:confirm)
    end
  end

  describe "#dismiss_modal" do
    it "sends a Page.handleJavaScriptDialog" do
      expect(browser).to receive(:send_cmd)
        .with("Page.handleJavaScriptDialog",
              accept: false)
      subject.dismiss_modal(:confirm)
    end
  end
end
