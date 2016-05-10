require 'feature_helper'
require 'api_test_helper'

RSpec.describe 'User returns from an IDP with an AuthnResponse' do
  it 'will redirect the user to /confirmation when successfully registered' do
    set_session_cookies!
    api_request = stub_api_response('idpResult' => 'SUCCESS', 'isRegistration' => true)

    visit('/test-saml')
    click_button 'saml-response-post'

    expect(page).to have_current_path '/confirmation'
    expect(api_request).to have_been_made.once
  end

  it 'will redirect the user to /start when they cancel registration at the IDP' do
    set_session_cookies!

    api_request = stub_api_response('idpResult' => 'CANCEL', 'isRegistration' => true)

    visit('/test-saml')
    click_button 'saml-response-post'

    expect(page).to have_current_path '/start'
    expect(api_request).to have_been_made.once
  end

  it 'will redirect the user to /failed-registration when they failed registration at the IDP' do
    set_session_cookies!
    api_request = stub_api_response('idpResult' => 'OTHER', 'isRegistration' => true)
    visit('/test-saml')
    click_button 'saml-response-post'

    expect(page).to have_current_path '/failed-registration'
    expect(api_request).to have_been_made.once
  end

  it 'will redirect the user to /failed-sign-in when they failed sign in at the IDP' do
    set_session_cookies!
    api_request = stub_api_response('idpResult' => 'OTHER', 'isRegistration' => false)

    visit('/test-saml')
    click_button 'saml-response-post'

    expect(page).to have_current_path '/failed-sign-in'
    expect(api_request).to have_been_made.once
  end

  it 'will redirect the user to /response-processing on successful sign in at the IDP' do
    set_session_cookies!

    api_request = stub_api_response('idpResult' => 'SUCCESS', 'isRegistration' => false)

    visit('/test-saml')
    click_button 'saml-response-post'

    expect(page).to have_current_path '/response-processing'
    expect(api_request).to have_been_made.once
  end
end

private

def stub_api_response(response)
  authn_response_body = {
    SessionProxy::PARAM_SAML_RESPONSE => 'my-saml-response',
    SessionProxy::PARAM_RELAY_STATE => 'my-relay-state',
    SessionProxy::PARAM_ORIGINATING_IP => '<PRINCIPAL IP ADDRESS COULD NOT BE DETERMINED>'
  }

  stub_request(:put, api_uri('session/idp-authn-response'))
    .with(body: authn_response_body)
    .to_return(body: response.to_json, status: 200)
end
