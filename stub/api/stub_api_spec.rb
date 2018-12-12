require 'json'
require 'rspec'
require 'rack/test'
require_relative 'stub_api.rb'

require 'active_model'

APP_HOME = File.join(File.dirname(__FILE__), '../../')
$LOAD_PATH << File.join(APP_HOME, 'app/models')

require 'api/response'
require 'country'
require 'identity_provider'
require 'idp_list_response'
require 'select_idp_response'
require 'outbound_saml_message'
require 'idp_authn_response'
require 'country_authn_response'

describe StubApi do
  include Rack::Test::Methods

  def app
    StubApi
  end

  def last_response_json
   JSON.parse(last_response.body)
  end

  context '#get /config/idps/idp-list/http%3A%2F%2Fwww.test-rp.gov.uk%2FSAML2%2FMD/LEVEL_1' do
    it 'should respond with valid IdpListResponse', skip_before: true do
      get '/config/idps/idp-list/http%3A%2F%2Fwww.test-rp.gov.uk%2FSAML2%2FMD/LEVEL_1'
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

  context '#post /SAML2/SSO/API/RECEIVER/EidasResponse/POST' do
    it 'should respond with valid hash', skip_before: true do
      post '/SAML2/SSO/API/RECEIVER/EidasResponse/POST'
      expect(last_response).to be_ok
      response = CountryAuthnResponse.new(last_response_json)
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

  context '#get /api/countries/blah' do
    it 'should respond with valid hash', skip_before: true do
      get '/api/countries/blah'
      expect(last_response).to be_ok
      response = last_response_json
      expect(response.map { |country| country['simpleId'] }).to eq(['NL', 'ES', 'SE'])
    end
  end

  context '#get /policy/countries/session_id' do
    it 'should respond with valid countries', skip_before: true do
      get '/policy/countries/session_id'
      expect(last_response).to be_ok
      response = last_response_json
      expect(response.map { |country| country['simpleId'] }).to eq(['YY'])
    end
  end

  context '#post /policy/countries/session_id/countryCode' do
    it 'should respond with 200', skip_before: true do
      post '/policy/countries/session_id/countryCode'
      expect(last_response).to be_ok
    end
  end
end
