require 'spec_helper'
require 'rails_helper'
require 'models/session_proxy'
require 'cookie_names'

X_FORWARDED_FOR = 'X-Forwarded-For'.freeze

describe SessionProxy do
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
  let(:session_proxy) { SessionProxy.new(api_client, originating_ip_store) }
  let(:ip_address) { '127.0.0.1' }

  include SessionEndpoints
  def endpoint(suffix_path)
    session_endpoint(session_id, suffix_path)
  end

  describe('#create_session') do
    let(:api_response) {
      {
          'sessionId' => session_id,
          'sessionStartTime' => 'my-session-start-time',
          'transactionSimpleId' => 'transaction-simple-id',
          'transactionEntityId' => 'http://www.test-rp.gov.uk/SAML2/MD',
          'idps' => [{ 'simpleId' => 'stub-idp-one', 'entityId' => 'http://idcorp.com' }],
          'levelsOfAssurance' => %w(LEVEL_1 LEVEL_2),
          'transactionSupportsEidas' => false
      }
    }

    it 'should return session information when a session is created' do
      authn_request_body = {
          SessionProxy::PARAM_SAML_REQUEST => 'my-saml-request',
          SessionProxy::PARAM_RELAY_STATE => 'my-relay-state',
          SessionProxy::PARAM_ORIGINATING_IP => ip_address
      }
      expect(api_client).to receive(:post).with(path, authn_request_body).and_return(api_response)
      expect(originating_ip_store).to receive(:get).and_return(ip_address)
      response = session_proxy.create_session('my-saml-request', 'my-relay-state')
      expect(response).to be_valid
      expect(response.session_id).to eq session_id
      expect(response.transaction_simple_id).to eq 'transaction-simple-id'
      expect(response.levels_of_assurance).to eq %w(LEVEL_1 LEVEL_2)
    end

    it 'should raise an Error if no session values are returned' do
      ip_address = '127.0.0.1'
      authn_request_body = {
          SessionProxy::PARAM_SAML_REQUEST => 'my-saml-request',
          SessionProxy::PARAM_RELAY_STATE => 'my-relay-state',
          SessionProxy::PARAM_ORIGINATING_IP => ip_address
      }
      expect(api_client).to receive(:post).with(path, authn_request_body).and_return({})
      expect(originating_ip_store).to receive(:get).and_return(ip_address)
      expect {
        session_proxy.create_session('my-saml-request', 'my-relay-state')
      }.to raise_error Api::Response::ModelError, "Session can't be blank, Transaction simple can't be blank, Levels of assurance can't be blank, Transaction entity can't be blank, Transaction supports eidas is not included in the list"
    end
  end

  describe('#get_countries') do
    countries_json = [
      { 'entityId' => 'http://netherlandsEnitity.nl', 'simpleId' => 'NL', 'enabled' => false },
      { 'entityId' => 'http://spainEnitity.es', 'simpleId' => 'ES', 'enabled' => true }
    ]
    let(:api_response) { countries_json }

    it 'should retrieve countries' do
      expect(api_client).to receive(:get).with('/api/countries/my-session-id').and_return(api_response)

      response = session_proxy.get_countries(session_id)
      expect(response.countries.count).to eq(2)
      response.countries.each do |country|
        case country.simple_id
        when 'ES'
          expect(country).to have_attributes(simple_id: 'ES',
                                             entity_id: 'http://spainEnitity.es',
                                             enabled: true)
        when 'NL'
          expect(country).to have_attributes(simple_id: 'NL',
                                             entity_id: 'http://netherlandsEnitity.nl',
                                             enabled: false)
        else
          fail('Invalid list of countries')
        end
      end
    end
  end

  describe('#idp_authn_request') do
    it 'should get an IDP authn request' do
      authn_request = {
        'location' => 'some-location',
        'samlRequest' => 'a-saml-request',
        'relayState' => 'relay-state',
        'registration' => false
      }
      ip_address = '1.1.1.1'
      expect(api_client).to receive(:get)
        .with(endpoint(SessionProxy::IDP_AUTHN_REQUEST_SUFFIX), headers: { X_FORWARDED_FOR => ip_address })
        .and_return(authn_request)
      expect(originating_ip_store).to receive(:get).and_return(ip_address)
      result = session_proxy.idp_authn_request(session_id)
      attributes = {
          'location' => 'some-location',
          'saml_request' => 'a-saml-request',
          'relay_state' => 'relay-state',
          'registration' => false
      }
      expect(result).to have_attributes(attributes)
    end

    it 'should fail to get an IDP authn request when fields are missing from response' do
      authn_request = {
          'location' => 'some-location',
          'relayState' => 'relay-state',
          'registration' => false
      }
      ip_address = '1.1.1.1'
      expect(api_client).to receive(:get)
        .with(endpoint(SessionProxy::IDP_AUTHN_REQUEST_SUFFIX), headers: { X_FORWARDED_FOR => ip_address })
        .and_return(authn_request)
      expect(originating_ip_store).to receive(:get).and_return(ip_address)
      expect {
        session_proxy.idp_authn_request(session_id)
      }.to raise_error Api::Response::ModelError, "Saml request can't be blank"
    end
  end

  describe '#idp_authn_response' do
    it 'should return a confirmation result' do
      ip_address = '1.2.3.4'
      expected_request = { 'samlResponse' => 'saml-response', 'relayState' => 'relay-state', SessionProxy::PARAM_ORIGINATING_IP => ip_address }
      expect(originating_ip_store).to receive(:get).and_return(ip_address)
      expect(api_client).to receive(:put)
        .with(endpoint(SessionProxy::IDP_AUTHN_RESPONSE_SUFFIX), expected_request)
        .and_return(
          'idpResult' => 'some-location',
          'isRegistration' => false,
          'loaAchieved' => 'LEVEL_2'
        )

      response = session_proxy.idp_authn_response(session_id, 'saml-response', 'relay-state')

      attributes = {
        idp_result: 'some-location',
        is_registration: false,
        loa_achieved: 'LEVEL_2'
      }
      expect(response).to have_attributes(attributes)
    end

    it 'should raise an error when fields are missing from the api response' do
      ip_address = '1.2.3.4'
      expected_request = { 'samlResponse' => 'saml-response', 'relayState' => 'relay-state', SessionProxy::PARAM_ORIGINATING_IP => ip_address }
      expect(originating_ip_store).to receive(:get).and_return(ip_address)
      expect(api_client).to receive(:put)
        .with(endpoint(SessionProxy::IDP_AUTHN_RESPONSE_SUFFIX), expected_request)
        .and_return({})

      expect {
        session_proxy.idp_authn_response(session_id, 'saml-response', 'relay-state')
      }.to raise_error Api::Response::ModelError, "Idp result can't be blank, Is registration is not included in the list"
    end

    it 'should raise an error when loa_achieved is not an accepted value' do
      ip_address = '1.2.3.4'
      expected_request = { 'samlResponse' => 'saml-response', 'relayState' => 'relay-state', SessionProxy::PARAM_ORIGINATING_IP => ip_address }
      expect(originating_ip_store).to receive(:get).and_return(ip_address)
      expect(api_client).to receive(:put)
        .with(endpoint(SessionProxy::IDP_AUTHN_RESPONSE_SUFFIX), expected_request)
        .and_return(
          'idpResult' => 'some-location',
          'isRegistration' => false,
          'loaAchieved' => 'something',
        )

      expect {
        session_proxy.idp_authn_response(session_id, 'saml-response', 'relay-state')
      }.to raise_error Api::Response::ModelError, 'Loa achieved is not included in the list'
    end
  end

  describe '#response_for_rp' do
    it 'should return an rp response' do
      expect(originating_ip_store).to receive(:get).and_return(ip_address)
      expect(api_client).to receive(:get)
        .with(endpoint(SessionProxy::RESPONSE_FOR_RP_SUFFIX), headers: { "X-Forwarded-For" => ip_address })
        .and_return(
          'postEndpoint' => 'http://www.example.com',
          'samlMessage' => 'a saml message',
          'relayState' => 'a relay state'
        )

      actual_response = session_proxy.response_for_rp(session_id)

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
        .with(endpoint(SessionProxy::RESPONSE_FOR_RP_SUFFIX), headers: { "X-Forwarded-For" => ip_address })
        .and_return('outcome' => 'BANANA')

      expect {
        session_proxy.response_for_rp(session_id)
      }.to raise_error(Api::Response::ModelError, "Location can't be blank, Saml message can't be blank")
    end
  end

  describe '#error_response_for_rp' do
    it 'should return an rp response' do
      expect(originating_ip_store).to receive(:get).and_return(ip_address)
      expect(api_client).to receive(:get)
        .with(endpoint(SessionProxy::ERROR_RESPONSE_FOR_RP_SUFFIX), headers: { "X-Forwarded-For" => ip_address })
        .and_return(
          'postEndpoint' => 'http://www.example.com',
          'samlMessage' => 'a saml message',
          'relayState' => 'a relay state'
        )

      actual_response = session_proxy.error_response_for_rp(session_id)

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
        .with(endpoint(SessionProxy::ERROR_RESPONSE_FOR_RP_SUFFIX), headers: { "X-Forwarded-For" => ip_address })
        .and_return('outcome' => 'BANANA')

      expect {
        session_proxy.error_response_for_rp(session_id)
      }.to raise_error(Api::Response::ModelError, "Location can't be blank, Saml message can't be blank")
    end
  end

  describe '#cycle_three_attribute_name' do
    it 'should return an attribute name' do
      expect(api_client).to receive(:get)
        .with(endpoint(SessionProxy::CYCLE_THREE_SUFFIX))
        .and_return('name' => 'verySpecialNumber')

      actual_response = session_proxy.cycle_three_attribute_name(session_id)

      expect(actual_response).to eql 'verySpecialNumber'
    end
  end

  describe '#submit_cycle_three_value' do
    it 'should post an attribute value' do
      expect(originating_ip_store).to receive(:get).and_return(ip_address)
      expect(api_client).to receive(:post)
        .with(endpoint(SessionProxy::CYCLE_THREE_SUFFIX),
              { 'value' => 'some value', 'originatingIp' => '127.0.0.1' },
              {}
             )

      session_proxy.submit_cycle_three_value(session_id, 'some value')
    end
  end

  describe '#cycle_three_cancel' do
    it 'should post to cancel api endpoint' do
      expect(api_client).to receive(:post)
        .with(endpoint(SessionProxy::CYCLE_THREE_CANCEL_SUFFIX),
              nil,
              {}
             )

      session_proxy.cycle_three_cancel(session_id)
    end
  end
end
