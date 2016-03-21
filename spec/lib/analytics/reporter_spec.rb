require 'spec_helper'
require 'analytics'
require 'models/cookie_names'

module Analytics
  describe Analytics::Reporter do
    site_id = 5
    let(:client) { double(:client) }
    let(:reporter) { Analytics::Reporter.new(client, site_id) }
    let(:request) { double(:request) }
    let(:action_name) { 'Sign In - idp-entity-id' }

    it 'should report all parameters to piwik' do
      expect(request).to receive(:cookies).and_return(CookieNames::PIWIK_VISITOR_ID => 'VISITOR_ID')
      expect(request).to receive(:url).and_return('www.thing.com')
      expect(Time).to receive(:now).and_return(Time.new(2080))
      expect(client).to receive(:report).with(
        'rec' => '1',
        'apiv' => '1',
        'idsite' => site_id,
        '_id' => 'VISITOR_ID',
        'action_name' => 'Sign In - idp-entity-id',
        'url' => 'www.thing.com',
        'cdt' => '2080-01-01 00:00:00',
        'cookie' => 'false',
        '_cvar' => '{"3":["SIGNIN_IDP","http://idcorp.com"]}'
      )
      reporter.report_custom_variable(request, action_name, '3' => ['SIGNIN_IDP', 'http://idcorp.com'])
    end

    it 'should report all parameters except _id to piwik when no cookie' do
      expect(request).to receive(:cookies).and_return({})
      expect(request).to receive(:url).and_return('www.thing.com')
      expect(Time).to receive(:now).and_return(Time.new(2080))
      expect(client).to receive(:report).with(
        'rec' => '1',
        'apiv' => '1',
        'idsite' => site_id,
        'action_name' => 'Sign In - idp-entity-id',
        'url' => 'www.thing.com',
        'cdt' => '2080-01-01 00:00:00',
        'cookie' => 'false'
      )
      reporter.report(request, action_name)
    end
  end
end
