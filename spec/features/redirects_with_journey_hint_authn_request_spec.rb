require 'feature_helper'
require 'api_test_helper'

describe 'pages redirect with journey hint parameter', type: :request do
  it 'will redirect the user to registration path when journey hint parameter is set to registration' do
    stub_session_creation
    post '/SAML2/SSO', params: { 'SAMLRequest' => 'my-saml-request', 'RelayState' => 'my-relay-state', 'journey_hint' => 'registration' }
    expect(response).to redirect_to begin_registration_path
  end

  it 'will redirect the user to registration path when journey hint parameter is set to registration and is case insensitive' do
    stub_session_creation
    post '/SAML2/SSO', params: { 'SAMLRequest' => 'my-saml-request', 'RelayState' => 'my-relay-state', 'journey_hint' => 'RegiStraTion' }
    expect(response).to redirect_to begin_registration_path
  end

  it 'will redirect the user to sign-in path when journey hint parameter is set to sign_in' do
    stub_session_creation
    post '/SAML2/SSO', params: { 'SAMLRequest' => 'my-saml-request', 'RelayState' => 'my-relay-state', 'journey_hint' => 'sign_in' }
    expect(response).to redirect_to begin_sign_in_path
  end

  it 'will redirect the user to non-repudiation path when journey hint parameter is present (not sign_in or registration)' do
    stub_session_creation
    post '/SAML2/SSO', params: { 'SAMLRequest' => 'my-saml-request', 'RelayState' => 'my-relay-state', 'journey_hint' => 'submission_confirmation' }
    expect(response).to redirect_to confirm_your_identity_path
  end

  it 'will redirect the user to non-repudiation path when journey hint parameter is present (not sign_in or registration)' do
    stub_session_creation
    post '/SAML2/SSO', params: { 'SAMLRequest' => 'my-saml-request', 'RelayState' => 'my-relay-state', 'journey_hint' => 'foobar' }
    expect(response).to redirect_to confirm_your_identity_path
  end

  it 'will redirect the user to start path when journey hint parameter is not present' do
    stub_session_creation
    post '/SAML2/SSO', params: { 'SAMLRequest' => 'my-saml-request', 'RelayState' => 'my-relay-state' }
    expect(response).to redirect_to start_path
  end
end
