require 'spec_helper'
require 'models/authn_request_proxy'
require 'models/cookie_names'

describe AuthnRequestProxy do
  let(:api_client) { double(:api_client) }
  let(:path) { "/SAML2/SSO" }

  context 'if request was successful' do
    it 'should be ok and return cookies' do
      authn_request_body = {
          'saml_request' => 'my-saml-request',
          'relay_state' => 'my-relay-state'
      }
      cookie_hash = {
          CookieNames::SESSION_ID_COOKIE_NAME => "my-session-id-cookie",
          CookieNames::SECURE_COOKIE_NAME => "my-secure-cookie",
          CookieNames::SESSION_STARTED_TIME_COOKIE_NAME => 'my-session-start-time'
      }
      expect(api_client).to receive(:post).with(path, authn_request_body).and_return(cookie_hash)
      cookies = AuthnRequestProxy.new(api_client).proxy('my-saml-request', 'my-relay-state')
      expect(cookies).to eq cookie_hash
    end
  end
end
