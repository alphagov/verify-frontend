require 'feature_helper'
require 'models/session_proxy'

RSpec.describe 'user sends authn requests' do
  let(:api_saml_endpoint) { api_uri('session') }
  context 'and it is received successfully' do
    let(:session_start_time) { create_session_start_time_cookie }
    it 'will redirect the user to /start' do
      cookie_hash = {
        CookieNames::SESSION_ID_COOKIE_NAME => "my-session-id-cookie",
        CookieNames::SECURE_COOKIE_NAME => "my-secure-cookie",
        CookieNames::SESSION_STARTED_TIME_COOKIE_NAME => session_start_time
      }
      authn_request_body = {
          SessionProxy::PARAM_SAML_REQUEST => 'my-saml-request',
          SessionProxy::PARAM_RELAY_STATE => 'my-relay-state',
          SessionProxy::PARAM_ORIGINATING_IP => '<PRINCIPAL IP ADDRESS COULD NOT BE DETERMINED>'
      }
      stub_request(:post, api_saml_endpoint).with(body: authn_request_body).to_return(body: cookie_hash.to_json, status: 201)
      visit('/test-saml')
      click_button "saml-post"
      expect(page).to have_content "Sign in with GOV.UK Verify"
      visit('/test-saml')
    end
    it 'will redirect the user to /confirm-your-identity when journey hint is set' do
      cookie_hash = {
        CookieNames::SESSION_ID_COOKIE_NAME => "my-session-id-cookie",
        CookieNames::SECURE_COOKIE_NAME => "my-secure-cookie",
        CookieNames::SESSION_STARTED_TIME_COOKIE_NAME => session_start_time
      }
      authn_request_body = {
          SessionProxy::PARAM_SAML_REQUEST => 'my-saml-request',
          SessionProxy::PARAM_RELAY_STATE => 'my-relay-state',
          SessionProxy::PARAM_ORIGINATING_IP => '<PRINCIPAL IP ADDRESS COULD NOT BE DETERMINED>'
      }
      stub_request(:post, api_saml_endpoint).with(body: authn_request_body).to_return(body: cookie_hash.to_json, status: 201)
      visit('/test-saml')
      click_button "saml-post-journey-hint"
      expect(page).to have_title "Confirm your identity - GOV.UK Verify - GOV.UK"
    end
  end
  context "and it is not received successfully" do
    it "will render the something went wrong page" do
      allow(Rails.logger).to receive(:error)
      expect(Rails.logger).to receive(:error).with(kind_of(ApiClient::Error)).at_least(:once)
      stub_request(:post, api_saml_endpoint).to_return(body: '{"message": "error"}', status: 500)
      visit('/test-saml')
      click_button "saml-post"
      expect(page).to have_content "Sorry, something went wrong"
    end
  end
end
