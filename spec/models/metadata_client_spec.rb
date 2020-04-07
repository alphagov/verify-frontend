require "spec_helper"
require "rails_helper"
require "webmock/rspec"

describe MetadataClient do
  let(:host) { "http://api.com" }
  let(:api_client) { MetadataClient.new(host) }

  it "should return metadata for service providers" do
    stub_request(:get, "#{host}/API/metadata/sp").and_return(status: 200, body: '{"saml": "<xml></xml>"}')
    result = api_client.sp_metadata
    expect(result).to eql("<xml></xml>")
  end

  it "should error with unexpected JSON" do
    stub_request(:get, "#{host}/API/metadata/sp").and_return(status: 200, body: '{"error": "<xml></xml>"}')
    expect { api_client.sp_metadata }.to raise_error "Received 200, but could not find saml on response"
  end

  it "should error with malformed JSON" do
    stub_request(:get, "#{host}/API/metadata/sp").and_return(status: 200, body: "<not-json/>")
    expect { api_client.sp_metadata }.to raise_error MultiJson::ParseError
  end

  it "should return metadata for identity providers" do
    stub_request(:get, "#{host}/API/metadata/idp").and_return(status: 200, body: '{"saml": "<xml></xml>"}')
    result = api_client.idp_metadata
    expect(result).to eql("<xml></xml>")
  end
end
