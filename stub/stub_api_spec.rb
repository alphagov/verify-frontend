require 'json'
require 'rspec'
require 'rack/test'
require './stub/stub_api'

require 'active_model'
require_relative '../app/models/api/response'
require_relative '../app/models/session_response'
require_relative '../app/models/identity_provider'
require_relative '../app/models/federation_info_response'
require_relative '../app/models/select_idp_response'
require_relative '../app/models/outbound_saml_message'
require_relative '../app/models/idp_authn_response'

describe StubApi do
  include Rack::Test::Methods

  def app
    StubApi
  end

  def last_response_json
   JSON.parse(last_response.body)
  end

  context '#post /api/session' do
    it 'should respond with valid SessionResponse' do
      post '/api/session'
      expect(last_response).to be_created
      response = SessionResponse.new(last_response_json)
      expect(response).to be_valid
    end
  end

  context '#get /api/session/federation' do
    it 'should respond with valid FederationInfoResponse' do
      get '/api/session/federation'
      expect(last_response).to be_ok
      response = FederationInfoResponse.new(last_response_json)
      expect(response).to be_valid
    end
  end

  context '#put /api/session/select-idp' do
    it 'should respond with valid SelectIdpResponse' do
      put '/api/session/select-idp'
      expect(last_response).to be_ok
      response = SelectIdpResponse.new(last_response_json)
      expect(response).to be_valid
    end
  end

  context '#get /api/session/idp-authn-request' do
    it 'should respond with valid OutboundSamlMessage' do
      get '/api/session/idp-authn-request'
      expect(last_response).to be_ok
      response = OutboundSamlMessage.new(last_response_json)
      expect(response).to be_valid
    end
  end

  context '#put /api/session/idp-authn-response' do
    it 'should respond with valid hash' do
      put '/api/session/idp-authn-response'
      expect(last_response).to be_ok
      response = IdpAuthnResponse.new(last_response_json)
      expect(response).to be_valid
    end
  end

  context '#get /api/transactions' do
    it 'should respond with valid hash' do
      get '/api/transactions'
      expect(last_response).to be_ok
      response = last_response_json
      expect(response['public']).to be_an(Array)
      expect(response['private']).to be_an(Array)
    end
  end
end
