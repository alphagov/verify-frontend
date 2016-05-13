require 'feature_helper'
require 'api_test_helper'

RSpec.describe 'User returns from an IDP with an AuthnResponse' do
  let(:session_cookies) { set_session_cookies! }
  let(:session_id) { session_cookies[CookieNames::SESSION_ID_COOKIE_NAME] }
  let(:stub_session) {
    page.set_rack_session(
      selected_idp: { entity_id: 'http://idcorp.com', simple_id: 'stub-idp-one' },
      selected_idp_was_recommended: true,
      transaction_simple_id: 'test-rp'
    )
  }
  before(:each) { session_cookies }

  it 'will show the something went wrong page when relay state and session id mismatch' do
    stub_transactions_list

    allow(Rails.logger).to receive(:warn)
    expect(Rails.logger).to receive(:warn).with(kind_of(Errors::WarningLevelError)).once

    visit('/test-saml?session-id=junk')
    click_button 'saml-response-post'

    expect(page).to have_content 'something went wrong'
  end

  it 'will redirect the user to /confirmation when successfully registered' do
    api_request = stub_api_response(session_id, 'idpResult' => 'SUCCESS', 'isRegistration' => true)
    stub_federation
    stub_session
    stub_request(:get, INTERNAL_PIWIK.url).with(query: hash_including({}))

    visit("/test-saml?session-id=#{session_id}")
    click_button 'saml-response-post'

    expect(page).to have_current_path '/confirmation'
    expect(api_request).to have_been_made.once
    piwik_request = { 'action_name' => 'Success - REGISTER_WITH_IDP' }
    expect(a_request(:get, INTERNAL_PIWIK.url).with(query: hash_including(piwik_request))).to have_been_made.once
  end

  it 'will redirect the user to a localised start page when they cancel sign in at the IDP' do
    set_journey_hint_cookie(nil, 'cy')
    api_request = stub_api_response(session_id, 'idpResult' => 'CANCEL', 'isRegistration' => false)

    stub_request(:get, INTERNAL_PIWIK.url).with(query: hash_including({}))
    visit("/test-saml?session-id=#{session_id}")
    click_button 'saml-response-post'

    expect(page).to have_current_path '/dechrau'
    expect(api_request).to have_been_made.once
    piwik_request = { 'action_name' => 'Cancel - SIGN_IN_WITH_IDP' }
    expect(a_request(:get, INTERNAL_PIWIK.url).with(query: hash_including(piwik_request))).to have_been_made.once
  end

  it 'will redirect the user to /failed-registration when they cancel at the IDP' do
    page.set_rack_session(
      selected_idp: { entity_id: 'http://idcorp.com', simple_id: 'stub-idp-one' },
    )
    api_request = stub_api_response(session_id, 'idpResult' => 'CANCEL', 'isRegistration' => true)
    visit("/test-saml?session-id=#{session_id}")
    click_button 'saml-response-post'

    expect(page).to have_current_path '/failed-registration'
    expect(api_request).to have_been_made.once
  end

  it 'will redirect the user to /failed-registration when they failed registration at the IDP' do
    page.set_rack_session(
      selected_idp: { entity_id: 'http://idcorp.com', simple_id: 'stub-idp-one' },
    )
    api_request = stub_api_response(session_id, 'idpResult' => 'OTHER', 'isRegistration' => true)
    visit("/test-saml?session-id=#{session_id}")
    click_button 'saml-response-post'

    expect(page).to have_current_path '/failed-registration'
    expect(api_request).to have_been_made.once
  end

  it 'will redirect the user to /failed-sign-in when they failed sign in at the IDP' do
    api_request = stub_api_response(session_id, 'idpResult' => 'OTHER', 'isRegistration' => false)

    stub_request(:get, INTERNAL_PIWIK.url).with(query: hash_including({}))
    visit("/test-saml?session-id=#{session_id}")
    click_button 'saml-response-post'

    expect(page).to have_current_path '/failed-sign-in'
    expect(api_request).to have_been_made.once
    piwik_request = { 'action_name' => 'Failure - SIGN_IN_WITH_IDP' }
    expect(a_request(:get, INTERNAL_PIWIK.url).with(query: hash_including(piwik_request))).to have_been_made.once
  end

  it 'will redirect the user to /response-processing on successful sign in at the IDP' do
    api_request = stub_api_response(session_id, 'idpResult' => 'SUCCESS', 'isRegistration' => false)

    visit("/test-saml?session-id=#{session_id}")
    click_button 'saml-response-post'

    expect(page).to have_current_path '/response-processing'
    expect(api_request).to have_been_made.once
  end
end

private

def stub_api_response(relay_state, response)
  authn_response_body = {
    SessionProxy::PARAM_SAML_RESPONSE => 'my-saml-response',
    SessionProxy::PARAM_RELAY_STATE => relay_state,
    SessionProxy::PARAM_ORIGINATING_IP => '<PRINCIPAL IP ADDRESS COULD NOT BE DETERMINED>'
  }

  stub_request(:put, api_uri('session/idp-authn-response'))
    .with(body: authn_response_body)
    .to_return(body: response.to_json, status: 200)
end
