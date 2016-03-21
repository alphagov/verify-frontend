require 'spec_helper'
require 'analytics'
require 'rails_helper'

module Analytics
  describe Analytics::PiwikClient do
    let(:http) { double(:http) }
    let(:context) { double(:context) }
    let(:piwik_client) { PiwikClient.new(context) }

    it 'should make a get request with params' do
      params = { 'param_1' => 'param_1_val' }
      expect(HTTP).to receive(:headers).and_return(http)
      expect(http).to receive(:get).with(PIWIK.url, params: params, ssl_context: context)

      piwik_client.report(params)
    end

    it 'should log errors and continue' do
      expect(HTTP).to receive(:headers).and_return(http)
      expect(http).to receive(:get).and_raise(HTTP::Error)
      expect(Rails.logger).to receive(:error)

      piwik_client.report({})
    end
  end
end
