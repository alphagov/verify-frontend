require 'feature_helper'
require 'api_test_helper'
require 'piwik_test_helper'

RSpec.describe 'User returns from an IDP with an AuthnResponse' do
  let(:session_id) do
    session = set_session!
    session[:verify_session_id]
  end
  let(:stub_session) {
    page.set_rack_session(
      selected_idp: { entity_id: 'http://idcorp.com', simple_id: 'stub-idp-one' },
      selected_idp_was_recommended: true,
      transaction_simple_id: 'test-rp'
    )
  }

  before :each do
    set_session_and_session_cookies!
    stub_api_idp_list
  end

  it 'will show the something went wrong page when relay state and session id mismatch' do
    stub_transactions_list

    allow(Rails.logger).to receive(:warn)
    expect(Rails.logger).to receive(:warn).with(kind_of(Errors::WarningLevelError)).once

    visit('/test-saml?session-id=junk')
    click_button 'saml-response-post'

    expect(page).to have_content 'something went wrong'
  end

  it 'will redirect the user to /confirmation when successfully registered' do
    api_request = stub_api_authn_response(session_id, 'idpResult' => 'SUCCESS', 'isRegistration' => true, 'loaAchieved' => 'LEVEL_2')
    stub_session
    stub_request(:get, INTERNAL_PIWIK.url).with(query: hash_including({}))

    visit("/test-saml?session-id=#{session_id}")
    click_button 'saml-response-post'

    expect(page).to have_current_path '/confirmation'
    expect(api_request).to have_been_made.once
    expect(a_request(:get, INTERNAL_PIWIK.url)
      .with(query: hash_including('action_name' => 'Success - REGISTER_WITH_IDP at LOA LEVEL_2'))).to have_been_made.once
  end

  it 'will redirect the user to /failed-registration when they cancel at the IDP' do
    page.set_rack_session(
      selected_idp: { entity_id: 'http://idcorp.com', simple_id: 'stub-idp-one' },
      transaction_simple_id: 'test-rp'
    )
    api_request = stub_api_authn_response(session_id, 'idpResult' => 'CANCEL', 'isRegistration' => true, 'loaAchieved' => nil)
    visit("/test-saml?session-id=#{session_id}")
    click_button 'saml-response-post'

    expect(page).to have_current_path '/failed-registration'
    expect(api_request).to have_been_made.once
  end

  it 'will redirect the user to /failed-registration when they failed registration at the IDP' do
    page.set_rack_session(
      selected_idp: { entity_id: 'http://idcorp.com', simple_id: 'stub-idp-one' },
      transaction_simple_id: 'test-rp'
    )
    api_request = stub_api_authn_response(session_id, 'idpResult' => 'OTHER', 'isRegistration' => true, 'loaAchieved' => nil)
    visit("/test-saml?session-id=#{session_id}")
    click_button 'saml-response-post'

    expect(page).to have_current_path '/failed-registration'
    expect(api_request).to have_been_made.once
  end

  it 'will redirect the user to /failed-sign-in when they failed sign in at the IDP' do
    api_request = stub_api_authn_response(session_id, 'idpResult' => 'OTHER', 'isRegistration' => false, 'loaAchieved' => nil)
    page.set_rack_session(
      selected_idp: { entity_id: 'http://idcorp.com', simple_id: 'stub-idp-one' })

    stub_request(:get, INTERNAL_PIWIK.url).with(query: hash_including({}))
    visit("/test-saml?session-id=#{session_id}")
    click_button 'saml-response-post'

    expect(page).to have_current_path '/failed-sign-in'
    expect(api_request).to have_been_made.once
    piwik_request = { 'action_name' => 'Failure - SIGN_IN_WITH_IDP' }
    expect(a_request(:get, INTERNAL_PIWIK.url).with(query: hash_including(piwik_request))).to have_been_made.once
  end

  it 'will redirect the user to /response-processing on successful sign in at the IDP' do
    stub_session
    stub_matching_outcome
    api_request = stub_api_authn_response(session_id, 'idpResult' => 'SUCCESS', 'isRegistration' => false, 'loaAchieved' => 'LEVEL_2')

    visit("/test-saml?session-id=#{session_id}")
    click_button 'saml-response-post'

    expect(page).to have_current_path '/response-processing'
    expect(api_request).to have_been_made.once
    expect(a_request(:get, INTERNAL_PIWIK.url)
               .with(query: hash_including('action_name' => 'Success - SIGN_IN_WITH_IDP at LOA LEVEL_2'))).to have_been_made.once
  end

  it 'will redirect the user to /response-processing on successful sign in at the Country' do
    stub_session
    stub_matching_outcome
    api_request = stub_api_country_authn_response(session_id, 'countryResult' => 'SUCCESS', 'isRegistration' => false, 'loaAchieved' => 'LEVEL_2')

    visit("/test-saml?session-id=#{session_id}")
    click_button 'saml-eidas-response-post'

    expect(page).to have_current_path '/response-processing'
    expect(api_request).to have_been_made.once
  end
end
