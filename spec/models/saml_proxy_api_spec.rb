require 'spec_helper'
require 'rails_helper'
require 'models/saml_proxy_api'
require 'cookie_names'

X_FORWARDED_FOR = 'X-Forwarded-For'.freeze

describe SamlProxyApi do
  let(:api_client) { double(:api_client) }
  let(:originating_ip_store) { double(:originating_ip_store) }
  let(:path) { '/api/session' }
  let(:session_id) { 'my-session-id' }
  let(:cookies) {
    {
        CookieNames::SESSION_ID_COOKIE_NAME => session_id,
    }
  }
  let(:session) {
    {
        start_time: 'my-session-start-time'
    }
  }
  let(:saml_proxy_api) { SamlProxyApi.new(api_client, originating_ip_store) }
  let(:ip_address) { '127.0.0.1' }

  include SamlProxyEndpoints

  describe '#response_for_rp' do
    it 'should return an rp response' do
      expect(originating_ip_store).to receive(:get).and_return(ip_address)
      expect(api_client).to receive(:get)
        .with(response_for_rp_endpoint(session_id), headers: { "X-Forwarded-For" => ip_address })
        .and_return('postEndpoint' => 'http://www.example.com',
                    'samlMessage' => 'a saml message',
                    'relayState' => 'a relay state')

      actual_response = saml_proxy_api.response_for_rp(session_id)

      expected_attributes = {
          'location' => 'http://www.example.com',
          'saml_message' => 'a saml message',
          'relay_state' => 'a relay state'
      }
      expect(actual_response).to have_attributes(expected_attributes)
    end

    it 'should raise an error when the API responds with an unknown value' do
      expect(originating_ip_store).to receive(:get).and_return(ip_address)
      expect(api_client).to receive(:get)
        .with(response_for_rp_endpoint(session_id), headers: { "X-Forwarded-For" => ip_address })
        .and_return('outcome' => 'BANANA')

      expect {
        saml_proxy_api.response_for_rp(session_id)
      }.to raise_error(Api::Response::ModelError, "Location can't be blank, Saml message can't be blank")
    end
  end

  describe '#error_response_for_rp' do
    it 'should return an rp response' do
      expect(originating_ip_store).to receive(:get).and_return(ip_address)
      expect(api_client).to receive(:get)
        .with(error_response_for_rp_endpoint(session_id), headers: { "X-Forwarded-For" => ip_address })
        .and_return('postEndpoint' => 'http://www.example.com',
                    'samlMessage' => 'a saml message',
                    'relayState' => 'a relay state')

      actual_response = saml_proxy_api.error_response_for_rp(session_id)

      expected_attributes = {
          'location' => 'http://www.example.com',
          'saml_message' => 'a saml message',
          'relay_state' => 'a relay state'
      }
      expect(actual_response).to have_attributes(expected_attributes)
    end

    it 'should raise an error when the API responds with an unknown value' do
      expect(originating_ip_store).to receive(:get).and_return(ip_address)
      expect(api_client).to receive(:get)
        .with(error_response_for_rp_endpoint(session_id), headers: { "X-Forwarded-For" => ip_address })
        .and_return('outcome' => 'BANANA')

      expect {
        saml_proxy_api.error_response_for_rp(session_id)
      }.to raise_error(Api::Response::ModelError, "Location can't be blank, Saml message can't be blank")
    end
  end
end
