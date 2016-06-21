require 'spec_helper'
require 'rails_helper'
require 'models/session_proxy'
require 'models/cookie_names'

describe SessionProxy do
  let(:api_client) { double(:api_client) }
  let(:originating_ip_store) { double(:originating_ip_store) }
  let(:path) { '/session' }
  let(:cookies) {
    {
      CookieNames::SESSION_ID_COOKIE_NAME => 'my-session-id-cookie',
      CookieNames::SECURE_COOKIE_NAME => 'my-secure-cookie',
      CookieNames::SESSION_STARTED_TIME_COOKIE_NAME => 'my-session-start-time',
    }
  }
  let(:ip_address) { '1.2.3.4' }
  let(:session_proxy) { SessionProxy.new(api_client, originating_ip_store) }

  describe('#create_session') do
    let(:api_response) {
      {
          'sessionId' => 'my-session-id-cookie',
          'secureCookie' => 'my-secure-cookie',
          'sessionStartTime' => 'my-session-start-time',
          'transactionSimpleId' => 'transaction-simple-id'
      }
    }

    it 'should return cookies when a session is created' do
      authn_request_body = {
          SessionProxy::PARAM_SAML_REQUEST => 'my-saml-request',
          SessionProxy::PARAM_RELAY_STATE => 'my-relay-state',
          SessionProxy::PARAM_ORIGINATING_IP => ip_address
      }
      expect(api_client).to receive(:post).with(path, authn_request_body).and_return(api_response)
      expect(originating_ip_store).to receive(:get).and_return(ip_address)
      response = session_proxy.create_session('my-saml-request', 'my-relay-state')
      expect(response).to be_valid
      expect(response.session_id).to eq 'my-session-id-cookie'
      expect(response.session_start_time).to eq 'my-session-start-time'
      expect(response.secure_cookie).to eq 'my-secure-cookie'
      expect(response.transaction_simple_id).to eq 'transaction-simple-id'
    end

    it 'should raise an Error if no session values are returned' do
      authn_request_body = {
          SessionProxy::PARAM_SAML_REQUEST => 'my-saml-request',
          SessionProxy::PARAM_RELAY_STATE => 'my-relay-state',
          SessionProxy::PARAM_ORIGINATING_IP => ip_address
      }
      expect(api_client).to receive(:post).with(path, authn_request_body).and_return({})
      expect(originating_ip_store).to receive(:get).and_return(ip_address)
      expect {
        session_proxy.create_session('my-saml-request', 'my-relay-state')
      }.to raise_error Api::Response::ModelError, "Session can't be blank, Session start time can't be blank, Secure cookie can't be blank, Transaction simple can't be blank"
    end
  end

  describe('#identity_providers') do
    it 'should return a list of IDPs for the session' do
      idp = { 'simpleId' => 'idp', 'entityId' => 'something' }

      expect(api_client).to receive(:get)
        .with(SessionProxy::FEDERATION_INFO_PATH, cookies: cookies)
        .and_return('idps' => [idp], 'transactionSimpleId' => 'test-rp', 'transactionEntityId' => 'some-id')


      result = session_proxy.identity_providers(cookies)
      expect(result.size).to eql 1
      expect(result.first.simple_id).to eql 'idp'
      expect(result.first.entity_id).to eql 'something'
    end
  end

  describe('#select_idp') do
    it 'should select an IDP for the session' do
      body = { 'entityId' => 'an-entity-id', 'originatingIp' => ip_address, 'registration' => false }
      expect(api_client).to receive(:put)
        .with(SessionProxy::SELECT_IDP_PATH, body, cookies: cookies)
      expect(originating_ip_store).to receive(:get).and_return(ip_address)
      session_proxy.select_idp(cookies, 'an-entity-id')
    end

    it 'should select an IDP for the session when registering' do
      body = { 'entityId' => 'an-entity-id', 'originatingIp' => ip_address, 'registration' => true }
      expect(api_client).to receive(:put)
        .with(SessionProxy::SELECT_IDP_PATH, body, cookies: cookies)
      expect(originating_ip_store).to receive(:get).and_return(ip_address)
      session_proxy.select_idp(cookies, 'an-entity-id', true)
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
      params = { SessionProxy::PARAM_ORIGINATING_IP => ip_address }
      expect(api_client).to receive(:get)
        .with(SessionProxy::IDP_AUTHN_REQUEST_PATH, cookies: cookies, params: params)
        .and_return(authn_request)
      expect(originating_ip_store).to receive(:get).and_return(ip_address)
      result = session_proxy.idp_authn_request(cookies)
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
      params = { SessionProxy::PARAM_ORIGINATING_IP => ip_address }
      expect(api_client).to receive(:get)
        .with(SessionProxy::IDP_AUTHN_REQUEST_PATH, cookies: cookies, params: params)
        .and_return(authn_request)
      expect(originating_ip_store).to receive(:get).and_return(ip_address)
      expect {
        session_proxy.idp_authn_request(cookies)
      }.to raise_error Api::Response::ModelError, "Saml request can't be blank"
    end
  end

  describe '#idp_authn_response' do
    it 'should return a confirmation result' do
      expected_request = { 'samlResponse' => 'saml-response', 'relayState' => 'relay-state', SessionProxy::PARAM_ORIGINATING_IP => ip_address }
      expect(originating_ip_store).to receive(:get).and_return(ip_address)
      expect(api_client).to receive(:put)
        .with(SessionProxy::IDP_AUTHN_RESPONSE_PATH, expected_request, cookies: cookies)
        .and_return(
          'idpResult' => 'some-location',
          'isRegistration' => false,
        )

      response = session_proxy.idp_authn_response(cookies, 'saml-response', 'relay-state')

      attributes = {
        idp_result: 'some-location',
        is_registration: false,
      }
      expect(response).to have_attributes(attributes)
    end

    it 'should raise an error when fields are missing from the api response' do
      expected_request = { 'samlResponse' => 'saml-response', 'relayState' => 'relay-state', SessionProxy::PARAM_ORIGINATING_IP => ip_address }
      expect(originating_ip_store).to receive(:get).and_return(ip_address)
      expect(api_client).to receive(:put)
        .with(SessionProxy::IDP_AUTHN_RESPONSE_PATH, expected_request, cookies: cookies)
        .and_return({})

      expect {
        session_proxy.idp_authn_response(cookies, 'saml-response', 'relay-state')
      }.to raise_error Api::Response::ModelError, "Idp result can't be blank, Is registration is not included in the list"
    end
  end

  describe '#matching_outcome' do
    it 'should return a matching outcome' do
      expect(api_client).to receive(:get)
        .with(SessionProxy::MATCHING_OUTCOME_PATH, cookies: cookies)
        .and_return('outcome' => 'GOTO_HUB_LANDING_PAGE')

      response = session_proxy.matching_outcome(cookies)

      expect(response).to eql MatchingOutcomeResponse::GOTO_HUB_LANDING_PAGE
    end

    it 'should raise an error when the API responds with an unknown value' do
      expect(api_client).to receive(:get)
        .with(SessionProxy::MATCHING_OUTCOME_PATH, cookies: cookies)
        .and_return('outcome' => 'BANANA')

      expect {
        session_proxy.matching_outcome(cookies)
      }.to raise_error Api::Response::ModelError, 'Outcome BANANA is not an allowed value for a matching outcome'
    end
  end

  describe '#response_for_rp' do
    it 'should return an rp response' do
      expect(api_client).to receive(:get)
        .with(SessionProxy::RESPONSE_FOR_RP_PATH,
              cookies: cookies,
              params: { SessionProxy::PARAM_ORIGINATING_IP => ip_address }
             )
        .and_return(
          'postEndpoint' => 'http://www.example.com',
          'samlMessage' => 'a saml message',
          'relayState' => 'a relay state'
        )

      expect(originating_ip_store).to receive(:get).and_return(ip_address)
      actual_response = session_proxy.response_for_rp(cookies)

      expected_attributes = {
        'location' => 'http://www.example.com',
        'saml_message' => 'a saml message',
        'relay_state' => 'a relay state'
      }
      expect(actual_response).to have_attributes(expected_attributes)
    end

    it 'should raise an error when the API responds with an unknown value' do
      expect(api_client).to receive(:get)
        .with(SessionProxy::RESPONSE_FOR_RP_PATH,
              cookies: cookies,
              params: { SessionProxy::PARAM_ORIGINATING_IP => ip_address }
             )
        .and_return('outcome' => 'BANANA')

      expect(originating_ip_store).to receive(:get).and_return(ip_address)
      expect {
        session_proxy.response_for_rp(cookies)
      }.to raise_error(Api::Response::ModelError, "Location can't be blank, Saml message can't be blank")
    end
  end
  describe '#error_response_for_rp' do
    it 'should return an rp response' do
      expect(api_client).to receive(:get)
        .with(SessionProxy::ERROR_RESPONSE_FOR_RP_PATH,
              cookies: cookies,
              params: { SessionProxy::PARAM_ORIGINATING_IP => ip_address }
             )
        .and_return(
          'postEndpoint' => 'http://www.example.com',
          'samlMessage' => 'a saml message',
          'relayState' => 'a relay state'
        )

      expect(originating_ip_store).to receive(:get).and_return(ip_address)
      actual_response = session_proxy.error_response_for_rp(cookies)

      expected_attributes = {
        'location' => 'http://www.example.com',
        'saml_message' => 'a saml message',
        'relay_state' => 'a relay state'
      }
      expect(actual_response).to have_attributes(expected_attributes)
    end

    it 'should raise an error when the API responds with an unknown value' do
      expect(api_client).to receive(:get)
        .with(SessionProxy::ERROR_RESPONSE_FOR_RP_PATH,
              cookies: cookies,
              params: { SessionProxy::PARAM_ORIGINATING_IP => ip_address }
             )
        .and_return('outcome' => 'BANANA')

      expect(originating_ip_store).to receive(:get).and_return(ip_address)
      expect {
        session_proxy.error_response_for_rp(cookies)
      }.to raise_error(Api::Response::ModelError, "Location can't be blank, Saml message can't be blank")
    end
  end
end
