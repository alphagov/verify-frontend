require 'json'
require 'rspec'
require 'rack/test'
require_relative 'stub_api.rb'

require 'active_model'

APP_HOME = File.join(File.dirname(__FILE__), '../../')
$LOAD_PATH << File.join(APP_HOME, 'app/models')
$LOAD_PATH << File.join(APP_HOME, 'lib')

require 'api/response'
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

  context '#get /config/idps/idp-list-for-registration/http%3A%2F%2Fwww.test-rp.gov.uk%2FSAML2%2FMD/LEVEL_1' do
    it 'should respond with valid IdpListResponse', skip_before: true do
      get '/config/idps/idp-list-for-registration/http%3A%2F%2Fwww.test-rp.gov.uk%2FSAML2%2FMD/LEVEL_1'
      expect(last_response).to be_ok
      response = IdpListResponse.new(last_response_json)
      expect(response).to be_valid
    end
  end

  context '#get /SAML2/SSO/API/SENDER/AUTHN_REQ' do
    it 'should respond with valid OutboundSamlMessage', skip_before: true do
      get '/SAML2/SSO/API/SENDER/AUTHN_REQ'
      expect(last_response).to be_ok
      response = OutboundSamlMessage.new(last_response_json)
      expect(response).to be_valid
    end
  end

  context '#post /SAML2/SSO/API/RECEIVER/Response/POST' do
    it 'should respond with valid hash', skip_before: true do
      post '/SAML2/SSO/API/RECEIVER/Response/POST'
      expect(last_response).to be_ok
      response = IdpAuthnResponse.new(last_response_json)
      expect(response).to be_valid
    end
  end

  context '#get /config/transactions/enabled' do
    it 'should respond with valid hash', skip_before: true do
      get '/config/transactions/enabled'
      expect(last_response).to be_ok
      response = last_response_json
      expect(response).to be_an(Array)
    end
  end
end
