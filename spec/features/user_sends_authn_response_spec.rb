require 'feature_helper'
require 'api_test_helper'

RSpec.describe 'User returns from an IDP with an AuthnResponse' do
  let(:api_authn_response_endpoint) { api_uri('session/idp-authn-response') }

  it 'will redirect the user to /confirmation when successfully registered' do
    set_session_cookies!
    authn_response_body = {
        SessionProxy::PARAM_SAML_RESPONSE => 'my-saml-response',
        SessionProxy::PARAM_RELAY_STATE => 'my-relay-state',
        SessionProxy::PARAM_ORIGINATING_IP => '<PRINCIPAL IP ADDRESS COULD NOT BE DETERMINED>'
    }
    api_response = {
        'idpResult' => 'idp-result',
        'isRegistration' => true,
    }
    api_request = stub_request(:put, api_authn_response_endpoint)
      .with(body: authn_response_body)
      .to_return(body: api_response.to_json, status: 200)

    visit('/test-saml')
    click_button 'saml-response-post'

    expect(page).to have_title 'Confirmation - GOV.UK Verify - GOV.UK'
    expect(api_request).to have_been_made.once
  end
end
