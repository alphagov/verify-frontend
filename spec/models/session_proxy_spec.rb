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
      ip_address = '127.0.0.1'
      authn_request_body = {
          SessionProxy::PARAM_SAML_REQUEST => 'my-saml-request',
          SessionProxy::PARAM_RELAY_STATE => 'my-relay-state',
          SessionProxy::PARAM_ORIGINATING_IP => ip_address
      }
      headers = { 'Accept' => 'application/vnd.uk.gov.verify.session+json, application/json' }
      expect(api_client).to receive(:post).with(path, authn_request_body, headers: headers).and_return(api_response)
      expect(originating_ip_store).to receive(:get).and_return(ip_address)
      response = session_proxy.create_session('my-saml-request', 'my-relay-state')
      expect(response).to be_valid
      expect(response.session_id).to eq 'my-session-id-cookie'
      expect(response.session_start_time).to eq 'my-session-start-time'
      expect(response.secure_cookie).to eq 'my-secure-cookie'
      expect(response.transaction_simple_id).to eq 'transaction-simple-id'
    end

    it 'should raise an Error if no session values are returned' do
      ip_address = '127.0.0.1'
      authn_request_body = {
          SessionProxy::PARAM_SAML_REQUEST => 'my-saml-request',
          SessionProxy::PARAM_RELAY_STATE => 'my-relay-state',
          SessionProxy::PARAM_ORIGINATING_IP => ip_address
      }
      headers = { 'Accept' => 'application/vnd.uk.gov.verify.session+json, application/json' }
      expect(api_client).to receive(:post).with(path, authn_request_body, headers: headers).and_return({})
      expect(originating_ip_store).to receive(:get).and_return(ip_address)
      expect {
        session_proxy.create_session('my-saml-request', 'my-relay-state')
      }.to raise_error Api::Response::ModelError, "Session can't be blank, Session start time can't be blank, Secure cookie can't be blank"
    end
  end

  describe('#federation_info_for_session') do
    it 'should return a list of IDPs for the session' do
      idp = { 'simpleId' => 'idp', 'entityId' => 'something' }

      expect(api_client).to receive(:get)
        .with(SessionProxy::FEDERATION_INFO_PATH, cookies: cookies)
        .and_return('idps' => [idp], 'transactionSimpleId' => 'test-rp', 'transactionEntityId' => 'some-id')

      result = session_proxy.federation_info_for_session(cookies)
      expect(result.idps.size).to eql 1
      expect(result.idps.first.simple_id).to eql 'idp'
      expect(result.idps.first.entity_id).to eql 'something'
    end

    it 'should fail to return federation info if transaction simple id is missing' do
      idp_list = []

      expect(api_client).to receive(:get)
        .with(SessionProxy::FEDERATION_INFO_PATH, cookies: cookies)
        .and_return('idps' => idp_list, 'transactionEntityId' => 'some-id')
      expect {
        session_proxy.federation_info_for_session(cookies)
      }.to raise_error Api::Response::ModelError, 'Transaction simple can\'t be blank'
    end
  end

  describe('#select_idp') do
    it 'should select an IDP for the session' do
      ip_address = '1.1.1.1'
      body = { 'entityId' => 'an-entity-id', 'originatingIp' => ip_address, 'registration' => false }
      encrypted_entity_id = 'bob'
      expect(api_client).to receive(:put)
        .with(SessionProxy::SELECT_IDP_PATH, body, cookies: cookies)
        .and_return('encryptedEntityId' => encrypted_entity_id)
      expect(originating_ip_store).to receive(:get).and_return(ip_address)
      result = session_proxy.select_idp(cookies, 'an-entity-id')
      expect(result.encrypted_entity_id).to eql encrypted_entity_id
    end

    it 'should select an IDP for the session when registering' do
      ip_address = '1.1.1.1'
      body = { 'entityId' => 'an-entity-id', 'originatingIp' => ip_address, 'registration' => true }
      encrypted_entity_id = 'bob'
      expect(api_client).to receive(:put)
        .with(SessionProxy::SELECT_IDP_PATH, body, cookies: cookies)
        .and_return('encryptedEntityId' => encrypted_entity_id)
      expect(originating_ip_store).to receive(:get).and_return(ip_address)
      result = session_proxy.select_idp(cookies, 'an-entity-id', true)
      expect(result.encrypted_entity_id).to eql encrypted_entity_id
    end

    it 'should fail to select an IDP for the session if encrypted entity id is missing' do
      ip_address = '1.1.1.1'
      body = { 'entityId' => 'an-entity-id', 'originatingIp' => ip_address, 'registration' => false }
      expect(api_client).to receive(:put)
        .with(SessionProxy::SELECT_IDP_PATH, body, cookies: cookies)
      expect(originating_ip_store).to receive(:get).and_return(ip_address)
      expect {
        session_proxy.select_idp(cookies, 'an-entity-id')
      }.to raise_error Api::Response::ModelError, "Encrypted entity can't be blank"
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
      ip_address = '1.1.1.1'
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
end
