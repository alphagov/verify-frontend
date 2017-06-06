require 'json'
require 'rspec'
require 'rack/test'
require_relative 'stub_api.rb'

require 'active_model'

APP_HOME = File.join(File.dirname(__FILE__), '../../')
$LOAD_PATH << File.join(APP_HOME, 'app/models')

require 'api/response'
require 'session_response'
require 'country'
require 'identity_provider'
require 'idp_list_response'
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
      post '/api/session', '{"relayState": "some_relay_state"}', {format: 'json'}
      expect(last_response).to be_created
      response = SessionResponse.new(last_response_json)
      expect(response).to be_valid
    end
  end

  context '#post /api/idp-list' do
    it 'should respond with valid IdpListResponse' do
      post '/api/idp-list'
      expect(last_response).to be_created
      response = IdpListResponse.new(last_response_json)
      expect(response).to be_valid
    end
  end

  context '#put /api/session/:session_id/select-idp' do
    it 'should respond with valid SelectIdpResponse' do
      put '/api/session/session_id/select-idp'
      expect(last_response).to be_ok
      response = SelectIdpResponse.new(last_response_json)
      expect(response).to be_valid
    end
  end

  context '#get /api/session/:session_id/idp-authn-request' do
    it 'should respond with valid OutboundSamlMessage' do
      get '/api/session/session_id/idp-authn-request'
      expect(last_response).to be_ok
      response = OutboundSamlMessage.new(last_response_json)
      expect(response).to be_valid
    end
  end

  context '#put /api/session/:session_id/idp-authn-response' do
    it 'should respond with valid hash' do
      put '/api/session/session_id/idp-authn-response'
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

  context '#get /api/countries/blah' do
    it 'should respond with valid hash' do
      get '/api/countries/blah'
      expect(last_response).to be_ok
      response = last_response_json
      expect(response.map { |country| country['simpleId'] }).to eq(['NL', 'ES', 'SE'])
    end
  end
end
