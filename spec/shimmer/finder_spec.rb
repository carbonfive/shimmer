require "spec_helper"
require "hashie/mash"
require "json"

RSpec.describe Capybara::Shimmer::Finder do
  subject { described_class.new(browser) }
  let(:browser) { instance_double(Capybara::Shimmer::Browser) }

  describe "#find_xpath" do
    it "finds when xpath query returns a single item" do
      query_result_wire_response = '
{"className":"Array","description":"Array(15)","objectId":"{\"injectedScriptId\":1,\"id\":46}","subtype":"array","type":"object"}
      '
      properties_result_wire_response = '
{"result":[{"configurable":true,"enumerable":true,"isOwn":true,"name":"0","value":{"className":"HTMLLIElement","description":"li","objectId":"{\"injectedScriptId\":1,\"id\":47}","subtype":"node","type":"object"},"writable":true},{"configurable":true,"enumerable":true,"isOwn":true,"name":"1","value":{"className":"HTMLLIElement","description":"li","objectId":"{\"injectedScriptId\":1,\"id\":48}","subtype":"node","type":"object"},"writable":true},{"configurable":true,"enumerable":true,"isOwn":true,"name":"2","value":{"className":"HTMLLIElement","description":"li","objectId":"{\"injectedScriptId\":1,\"id\":49}","subtype":"node","type":"object"},"writable":true}]}
'
      expected_query_result = Hashie::Mash.new(JSON.parse(query_result_wire_response))
      expected_properties_result = Hashie::Mash.new(JSON.parse(properties_result_wire_response))

      allow(Capybara::Shimmer::JavascriptBridge).to receive(:global_evaluate_script)
        .and_return(expected_query_result)
      allow(browser).to receive(:send_cmd)
        .with("Runtime.getProperties", objectId: "{\"injectedScriptId\":1,\"id\":46}", ownProperties: true)
        .and_return(expected_properties_result)
      allow(browser).to receive(:send_cmd)
        .with("DOM.describeNode", objectId: kind_of(String))
        .and_return(double(node: double(nodeId: 123, backendNodeId: 456)))
      allow(browser).to receive(:html_for)
        .with(backend_node_id: 456)
        .and_return("<body>Body</body>")
      result = subject.find_xpath("//body")
      node = result.first
      expect(node).to be_instance_of(Capybara::Shimmer::Node)
      expect(node.tag_name).to eq "body"
    end

    it "finds when xpath query returns multiple items" do
      query_result_wire_response = '
{"className":"Array","description":"Array(15)","objectId":"{\"injectedScriptId\":1,\"id\":1}","subtype":"array","type":"object"}
      '
      properties_result_wire_response = '
{"result":[
{"configurable":true,"enumerable":true,"isOwn":true,"name":"0","value":{"className":"HTMLLIElement","description":"li","objectId":"{\"injectedScriptId\":1,\"id\":2}","subtype":"node","type":"object"},"writable":true},
{"configurable":true,"enumerable":true,"isOwn":true,"name":"1","value":{"className":"HTMLLIElement","description":"li","objectId":"{\"injectedScriptId\":1,\"id\":3}","subtype":"node","type":"object"},"writable":true},
{"configurable":true,"enumerable":true,"isOwn":true,"name":"2","value":{"className":"HTMLLIElement","description":"li","objectId":"{\"injectedScriptId\":1,\"id\":4}","subtype":"node","type":"object"},"writable":true}
]}
'
      expected_query_result = Hashie::Mash.new(JSON.parse(query_result_wire_response))
      expected_properties_result = Hashie::Mash.new(JSON.parse(properties_result_wire_response))

      allow(Capybara::Shimmer::JavascriptBridge).to receive(:global_evaluate_script)
        .and_return(expected_query_result)
      allow(browser).to receive(:send_cmd)
        .with("Runtime.getProperties", objectId: "{\"injectedScriptId\":1,\"id\":1}", ownProperties: true)
        .and_return(expected_properties_result)
      allow(browser).to receive(:send_cmd)
        .with("DOM.describeNode", objectId: kind_of(String))
        .and_return(double(node: double(nodeId: 123, backendNodeId: 456)))
      allow(browser).to receive(:html_for)
        .with(backend_node_id: 456)
        .and_return("<li>LI node</li>")
      result = subject.find_xpath("//li")
      expect(result.count).to eq 3
      expect(result).to be_all { |node| node.instance_of?(Capybara::Shimmer::Node) }
      expect(result).to be_all { |node| node.tag_name == "li" }
    end

    it "returns empty array when xpath query returns no items" do
      query_result_wire_response = '
      {"className":"Array","description":"Array(0)","objectId":"{\"injectedScriptId\":1,\"id\":1}","subtype":"array","type":"object"}
      '
      properties_result_wire_response = '
{"result":[{"configurable":false,"enumerable":false,"isOwn":true,"name":"length","value":{"description":"0","type":"number","value":0},"writable":true},{"configurable":true,"enumerable":false,"isOwn":true,"name":"__proto__","value":{"className":"Array","description":"Array(0)","objectId":"{\"injectedScriptId\":1,\"id\":2}","subtype":"array","type":"object"},"writable":true}]}
'
      expected_query_result = Hashie::Mash.new(JSON.parse(query_result_wire_response))
      expected_properties_result = Hashie::Mash.new(JSON.parse(properties_result_wire_response))

      allow(Capybara::Shimmer::JavascriptBridge).to receive(:global_evaluate_script)
        .and_return(expected_query_result)
      allow(browser).to receive(:send_cmd)
        .with("Runtime.getProperties", objectId: "{\"injectedScriptId\":1,\"id\":1}", ownProperties: true)
        .and_return(expected_properties_result)
      result = subject.find_xpath("//asdfasdfq")
      expect(result).to be_empty
    end
  end
end
