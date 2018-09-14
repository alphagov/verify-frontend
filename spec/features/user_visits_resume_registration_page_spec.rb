require 'feature_helper'
require 'api_test_helper'
require 'piwik_test_helper'

RSpec.describe 'When the user visits the resume registration page and' do
  let(:idp_display_name) { 'IDCorp' }
  let(:rp_display_name) { 'Test RP' }
  let(:originating_ip) { '<PRINCIPAL IP ADDRESS COULD NOT BE DETERMINED>' }
  let(:idp_entity_id) { 'http://idcorp.com' }
  let(:encrypted_entity_id) { 'an-encrypted-entity-id' }
  let(:location) { '/test-idp-request-endpoint' }

  let(:select_idp_stub_request) {
    stub_session_select_idp_request(
      encrypted_entity_id,
      PolicyEndpoints::PARAM_SELECTED_ENTITY_ID => idp_entity_id, PolicyEndpoints::PARAM_PRINCIPAL_IP => originating_ip,
      PolicyEndpoints::PARAM_REGISTRATION => false, PolicyEndpoints::PARAM_REQUESTED_LOA => 'LEVEL_2'
    )
  }

  before(:each) do
    set_session_and_session_cookies!
    stub_api_idp_list_for_sign_in
    set_selected_idp_in_session(entity_id: idp_entity_id, simple_id: 'stub-idp-one')
    set_journey_hint_cookie(idp_entity_id, 'PENDING', 'en')
    stub_translations
  end

  context 'and has a cookie containing a PENDING state and valid IDP identifiers' do
    it 'displays correct text and button' do
      visit '/resume-registration'

      expect(page).to have_content t('hub.paused_registration.resume.intro', rp_name: rp_display_name, display_name: idp_display_name)
      expect(page).to have_content t('hub.paused_registration.resume.heading', rp_name: rp_display_name, display_name: idp_display_name)
      expect(page).to have_button t('hub.paused_registration.resume.continue', display_name: idp_display_name)
      expect(page).to have_content t('hub.paused_registration.resume.alternative_other_ways', rp_name: rp_display_name)
    end
  end

  context 'clicks continue to IDP with JS disabled' do
    it 'goes to "redirect-to-idp" page on submit' do
      visit '/resume-registration'
      select_idp_stub_request
      stub_session_idp_authn_request(originating_ip, location, false)

      click_button t('hub.paused_registration.resume.continue', display_name: idp_display_name)

      expect(page).to have_current_path(redirect_to_idp_sign_in_path)
      expect(select_idp_stub_request).to have_been_made.once
      expect(stub_piwik_request('action_name' => "Sign In - #{idp_display_name}")).to have_been_made.once
    end
  end

  context 'clicks continue to IDP with JS enabled', js: true do
    it 'will redirect the user to the IDP on Continue' do
      visit '/resume-registration'
      select_idp_stub_request
      stub_session_idp_authn_request(originating_ip, location, false)
      expect_any_instance_of(SignInController).to receive(:select_idp_ajax).and_call_original

      click_button t('hub.paused_registration.resume.continue', display_name: idp_display_name)
      expect(stub_piwik_request('action_name' => "Sign In - #{idp_display_name}")).to have_been_made.once
      expect(page).to have_current_path(location)
      expect(page).to have_content("SAML Request is 'a-saml-request'")
      expect(page).to have_content("relay state is 'a-relay-state'")
      expect(page).to have_content("registration is 'false'")
      expect(page).to have_content("language hint was 'en'")
      expect(select_idp_stub_request).to have_been_made.once
    end
  end
end
