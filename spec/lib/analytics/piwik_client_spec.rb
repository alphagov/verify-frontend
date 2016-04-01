require 'spec_helper'
require 'analytics/piwik_client'
require 'webmock/rspec'

module Analytics
  describe Analytics::PiwikClient do
    let(:http) { double(:http) }
    let(:context) { double(:context) }
    let(:url) { URI.parse("http://piwik.com/piwik.php") }
    let(:piwik_client) { PiwikClient.new(url) }

    it 'should make a get request with params' do
      params = { 'param_1' => 'param_1_val' }
      stub_request(:get, url).with(query: params).and_return(status: 200)
      thread = piwik_client.report(params)
      thread.join
      expect(a_request(:get, url).with(query: params)).to have_been_made.once
    end

    it 'should log errors and continue' do
      rails = double(:rails)
      stub_const("Rails", rails)
      logger = double(:logger)
      expect(rails).to receive(:logger).and_return logger
      expect(logger).to receive(:error)
      stub_request(:get, url).to_timeout
      thread = piwik_client.report({})
      thread.join
    end

    it 'should forward headers' do
      headers = {
        'User-Agent' => 'TEST USER AGENT',
        'Accept-Language' => 'en-GB',
        'X-Forwarded-For' => '192.168.0.1',
      }
      stub_request(:get, url).with(headers: headers).and_return(status: 200)
      thread = piwik_client.report({}, headers)
      thread.join
      expect(a_request(:get, url).with(headers: headers)).to have_been_made.once
    end

    context "can be not async" do
      it "will return the response" do
        stub_request(:get, url).and_return(status: 200)
        response = PiwikClient.new(url, async: false).report({}, {})
        expect(response.status).to eql 200
        expect(a_request(:get, url)).to have_been_made.once
      end
    end
  end
end
