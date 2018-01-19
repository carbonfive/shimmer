require 'spec_helper'

RSpec.describe Capybara::Shimmer::Driver do
  let(:app) { double("app") }
  let(:browser) { instance_double(Capybara::Shimmer::Browser) }
  let(:options) { { browser: browser } }
  subject { described_class.new(app, options) }

  describe '#current_url' do
    it 'delegates to the browser' do
      expect(browser).to receive(:current_url)
      subject.current_url
    end
  end
end
