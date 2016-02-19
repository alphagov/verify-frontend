require 'spec_helper'
require 'models/session_proxy'
require 'models/cookie_names'

describe SessionProxy do
  let(:api_client) { double(:api_client) }
  let(:path) { "/session" }

  context 'if request was successful' do
    it 'should be ok and return cookies' do
      x_forwarded_for = double(:x_forwarded_for)
      authn_request_body = {
          SessionProxy::PARAM_SAML_REQUEST => 'my-saml-request',
          SessionProxy::PARAM_RELAY_STATE => 'my-relay-state',
          SessionProxy::PARAM_ORIGINATING_IP => x_forwarded_for
      }
      cookie_hash = {
          CookieNames::SESSION_ID_COOKIE_NAME => "my-session-id-cookie",
          CookieNames::SECURE_COOKIE_NAME => "my-secure-cookie",
          CookieNames::SESSION_STARTED_TIME_COOKIE_NAME => 'my-session-start-time'
      }
      expect(api_client).to receive(:post).with(path, authn_request_body).and_return(cookie_hash)
      cookies = SessionProxy.new(api_client).proxy('my-saml-request', 'my-relay-state', x_forwarded_for)
      expect(cookies).to eq cookie_hash
    end
  end
end
