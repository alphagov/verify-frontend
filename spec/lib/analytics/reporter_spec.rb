require 'spec_helper'
require 'analytics'
require 'cookie_names'

module Analytics
  describe Analytics::Reporter do
    let(:site_id) { 5 }
    let(:client) { double(:client) }
    let(:reporter) { Analytics::Reporter.new(client, site_id) }
    let(:request) { double(:request) }
    let(:action_name) { 'Sign In - idp-entity-id' }
    let(:request_headers) {
      {
        'Accept-Language' => 'en-US,en;q=0.5',
        'X-Forwarded-For' => '1.1.1.1',
        'User-Agent' => 'my user agent',
      }
    }
    let(:piwik_headers) {
      {
        'Accept-Language' => 'en-US,en;q=0.5',
        'X-Forwarded-For' => '1.1.1.1',
        'User-Agent' => 'my user agent',
      }
    }
    let(:custom_variables) {
      {
        '1' => ['SOME_VAR', 'a-value']
      }
    }

    before :each do
      expect(request).to receive(:url).and_return('www.thing.com')
      expect(Time).to receive(:now).and_return(Time.new(2080))
    end

    it 'should report all parameters to piwik' do
      expect(request).to receive(:cookies).and_return(CookieNames::PIWIK_USER_ID => 'VISITOR_ID')
      allow(request).to receive(:referer).and_return('http://www.example.com')
      expect(request).to receive(:headers).and_return(request_headers)
      expect(client).to receive(:report).with(
        piwik_hash(
          action_name,
          'urlref' => 'http://www.example.com',
          'ref' => 'http://www.example.com',
          'uid' => 'VISITOR_ID',
        ),
        piwik_headers
      )
      reporter.report_action(request, action_name, custom_variables)
    end

    it 'should report event parameters to piwik' do
      expect(request).to receive(:cookies).and_return(CookieNames::PIWIK_USER_ID => 'VISITOR_ID')
      allow(request).to receive(:referer).and_return('http://www.example.com')
      expect(request).to receive(:headers).and_return(request_headers)
      expect(client).to receive(:report).with(
        piwik_hash(
          'trackEvent',
          'urlref' => 'http://www.example.com',
          'ref' => 'http://www.example.com',
          'uid' => 'VISITOR_ID',
          'e_c' => 'Event Category',
          'e_n' => 'Event Name',
          'e_a' => 'Event Action',
        ),
        piwik_headers
      )
      reporter.report_event(request, custom_variables, 'Event Category', 'Event Name', 'Event Action')
    end

    it 'should report all mandatory and exclude optional parameters' do
      expect(request).to receive(:cookies).and_return({})
      allow(request).to receive(:referer).and_return(nil)
      expect(request).to receive(:headers).and_return(request_headers)
      expect(client).to receive(:report).with(piwik_hash(action_name), piwik_headers)
      reporter.report_action(request, action_name, custom_variables)
    end

    it 'should send nil for X-Forwarded-For if not set in request.headers' do
      expect(request).to receive(:cookies).and_return({})
      allow(request).to receive(:referer).and_return(nil)
      expect(request).to receive(:headers).and_return(
        'Accept-Language' => 'en-US,en;q=0.5',
        'User-Agent' => 'my user agent',
      )
      expect(client).to receive(:report).with(
        piwik_hash(action_name),
        'Accept-Language' => 'en-US,en;q=0.5',
        'X-Forwarded-For' => nil,
        'User-Agent' => 'my user agent',
      )
      reporter.report_action(request, action_name, custom_variables)
    end

  private

    def piwik_hash(action_name, extra_fields = {})
      {
        'rec' => '1',
        'apiv' => '1',
        'idsite' => 5,
        'action_name' => action_name,
        'url' => 'www.thing.com',
        'cdt' => '2080-01-01 00:00:00',
        'cookie' => 'false',
        '_cvar' => '{"1":["SOME_VAR","a-value"]}',
      }.merge(extra_fields)
    end
  end
end
