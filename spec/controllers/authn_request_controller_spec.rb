require 'rails_helper'
require 'controller_helper'
require 'api_test_helper'

describe AuthnRequestController do
  let(:valid_rp) { 'test-rp-no-demo' }
  let(:valid_idp) { 'http://idcorp.com' }

  before :each do
    stub_session_creation
  end

  it 'will redirect the user to resume registration page if cookie state is PENDING' do
    front_journey_hint_cookie = {
        STATE: {
            IDP: valid_idp,
            RP: valid_rp,
            STATUS: 'PENDING'
        }
    }

    cookies.encrypted[CookieNames::VERIFY_FRONT_JOURNEY_HINT] = front_journey_hint_cookie.to_json
    post :rp_request, params: { 'SAMLRequest' => 'my-saml-request', 'RelayState' => 'my-relay-state' }
    expect(response).to redirect_to resume_registration_path
  end

  it 'will redirect the user to confirm your identity page if this is a non-repudiation even if cookie state is PENDING' do
    front_journey_hint_cookie = {
        STATE: {
            IDP: valid_idp,
            RP: valid_rp,
            STATUS: 'PENDING'
        }
    }

    cookies.encrypted[CookieNames::VERIFY_FRONT_JOURNEY_HINT] = front_journey_hint_cookie.to_json
    post :rp_request, params: { 'SAMLRequest' => 'my-saml-request', 'RelayState' => 'my-relay-state', 'journey_hint' => 'submission_confirmation' }
    expect(response).to redirect_to confirm_your_identity_path
  end

  it 'will redirect the user to default start page if cookie state is not PENDING' do
    front_journey_hint_cookie = {
        STATE: {
            IDP: valid_idp,
            RP: valid_rp,
            STATUS: 'SUCCESS'
        }
    }

    cookies.encrypted[CookieNames::VERIFY_FRONT_JOURNEY_HINT] = front_journey_hint_cookie.to_json
    post :rp_request, params: { 'SAMLRequest' => 'my-saml-request', 'RelayState' => 'my-relay-state' }
    expect(response).to redirect_to start_path
  end

  it 'will redirect the user to default start page if cookie state is missing' do
    front_journey_hint_cookie = {

    }

    cookies.encrypted[CookieNames::VERIFY_FRONT_JOURNEY_HINT] = front_journey_hint_cookie.to_json
    post :rp_request, params: { 'SAMLRequest' => 'my-saml-request', 'RelayState' => 'my-relay-state' }
    expect(response).to redirect_to start_path
  end

  it 'will redirect the user to default start page if cookie is missing' do
    post :rp_request, params: { 'SAMLRequest' => 'my-saml-request', 'RelayState' => 'my-relay-state' }
    expect(response).to redirect_to start_path
  end

  it 'will show error page when SAMLRequest param is missing' do
    post :rp_request, params: { 'RelayState' => 'my-relay-state' }
    expect(response).to have_http_status :bad_request
  end

  it 'will show error page when SAMLRequest param is empty string' do
    post :rp_request, params: { 'SAMLRequest' => '', 'RelayState' => 'my-relay-state' }
    expect(response).to have_http_status :bad_request
  end

  it 'will show error page when SAMLRequest param is nil' do
    post :rp_request, params: { 'SAMLRequest' => nil, 'RelayState' => 'my-relay-state' }
    expect(response).to have_http_status :bad_request
  end
end
