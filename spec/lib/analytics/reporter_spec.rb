require 'spec_helper'
require 'analytics'
require 'models/cookie_names'

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

    before :each do
      expect(request).to receive(:url).and_return('www.thing.com')
      expect(Time).to receive(:now).and_return(Time.new(2080))
    end

    it 'should report all parameters to piwik' do
      expect(request).to receive(:cookies).and_return(CookieNames::PIWIK_VISITOR_ID => 'VISITOR_ID')
      allow(request).to receive(:referer).and_return('http://www.example.com')
      expect(request).to receive(:headers).and_return(request_headers)
      expect(client).to receive(:report).with(
        piwik_hash(
          site_id,
          '_cvar' => '{"3":["SIGNIN_IDP","http://idcorp.com"]}',
          'urlref' => 'http://www.example.com',
          'ref' => 'http://www.example.com',
          '_id' => 'VISITOR_ID',
        ),
        piwik_headers
      )
      reporter.report_custom_variable(request, action_name, '3' => ['SIGNIN_IDP', 'http://idcorp.com'])
    end

    it 'should report all mandatory and exclude optional parameters' do
      expect(request).to receive(:cookies).and_return({})
      allow(request).to receive(:referer).and_return(nil)
      expect(request).to receive(:headers).and_return(request_headers)
      expect(client).to receive(:report).with(piwik_hash(site_id), piwik_headers)
      reporter.report(request, action_name)
    end

    it 'should send nil for X-Forwarded-For if not set in request.headers' do
      expect(request).to receive(:cookies).and_return({})
      allow(request).to receive(:referer).and_return(nil)
      expect(request).to receive(:headers).and_return(
        'Accept-Language' => 'en-US,en;q=0.5',
        'User-Agent' => 'my user agent',
      )
      expect(client).to receive(:report).with(piwik_hash(site_id),
        'Accept-Language' => 'en-US,en;q=0.5',
        'X-Forwarded-For' => nil,
        'User-Agent' => 'my user agent',
      )
      reporter.report(request, action_name)
    end

    private

    def piwik_hash(site_id, extra_fields = {})
      {
        'rec' => '1',
        'apiv' => '1',
        'idsite' => site_id,
        'action_name' => 'Sign In - idp-entity-id',
        'url' => 'www.thing.com',
        'cdt' => '2080-01-01 00:00:00',
        'cookie' => 'false',
      }.merge(extra_fields)
    end
  end
end
