require 'feature_helper'

RSpec.describe 'user sends authn requests' do
  let(:api_saml_endpoint) { 'http://localhost:50190/api/SAML2/SSO' }
  context 'and it is received successfully' do
    let(:session_start_time) {
      DateTime.now.to_i.to_s
    }
    it 'will redirect the user to /start' do
      cookie_hash = {
        CookieNames::SESSION_ID_COOKIE_NAME => "my-session-id-cookie",
        CookieNames::SECURE_COOKIE_NAME => "my-secure-cookie",
        CookieNames::SESSION_STARTED_TIME_COOKIE_NAME => session_start_time
      }
      authn_request_body = {
          'saml_request' => 'my-saml-request',
          'relay_state' => 'my-relay-state'
      }
      stub_request(:post, api_saml_endpoint).with(body: authn_request_body).to_return(body: cookie_hash.to_json, status: 201)
      visit('/test-saml')
      click_button "saml-post"
      expect(page).to have_content "Sign in with GOV.UK Verify"
    end
  end
  context "and it is not received successfully" do
    it "will render the something went wrong page" do
      allow(Rails.logger).to receive(:error)
      expect(Rails.logger).to receive(:error).with(kind_of(ApiClient::Error)).at_least(:once)
      stub_request(:post, api_saml_endpoint).to_return(body: 'oh mah gawd', status: 500)
      visit('/test-saml')
      click_button "saml-post"
      expect(page).to have_content "Sorry, something went wrong"
    end
  end
end
