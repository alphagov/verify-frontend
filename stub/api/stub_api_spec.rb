require 'json'
require 'rspec'
require 'rack/test'
require_relative 'stub_api.rb'

require 'active_model'

APP_HOME = File.join(File.dirname(__FILE__), '../../')
$LOAD_PATH << File.join(APP_HOME, 'app/models')

require 'api/response'
require 'session_response'
require 'identity_provider'
require 'federation_info_response'
require 'select_idp_response'
require 'outbound_saml_message'
require 'idp_authn_response'

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
