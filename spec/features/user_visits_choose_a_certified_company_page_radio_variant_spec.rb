require 'feature_helper'
require 'api_test_helper'
require 'i18n'
require 'piwik_test_helper'

describe 'When the user visits the choose a certified company page with variant AB cookie' do
  let(:originating_ip) { '<PRINCIPAL IP ADDRESS COULD NOT BE DETERMINED>' }
  let(:encrypted_entity_id) { 'an-encrypted-entity-id' }
  let(:location) { '/test-idp-request-endpoint' }
  let(:idp_entity_id) { 'loa1-entity-id' }
  let(:select_idp_stub_request) {
    stub_session_select_idp_request(
      encrypted_entity_id,
       PolicyEndpoints::PARAM_SELECTED_ENTITY_ID => idp_entity_id, PolicyEndpoints::PARAM_PRINCIPAL_IP => originating_ip, PolicyEndpoints::PARAM_REGISTRATION => true
    )
  }

  before(:each) do
    set_session_and_ab_session_cookies!('loa1_radio_picker' => 'loa1_radio_picker_variant')
    stub_api_idp_list
    page.set_rack_session(
      transaction_simple_id: 'test-rp',
      requested_loa: 'LEVEL_1',
    )
  end

  context 'user is from an LOA1 service' do
    it 'only LEVEL_1 recommended IDPs are displayed' do
      visit '/choose-a-certified-company'

      expect(page).to have_current_path(choose_a_certified_company_path)

      within('#choose-a-certified-company-form') do
        expect(page).to have_button('Continue to the company website')
      end
    end
    it 'supports the welsh language' do
      visit '/dewis-cwmni-ardystiedig'

      expect(page).to have_title "Dewiswch gwmni ardystiedig - GOV.UK Verify - GOV.UK"
      expect(page).to have_css 'html[lang=cy]'
    end
  end

  context 'with JS enabled', js: true do
    it 'will redirect the user to the IDP on selecting IDP' do
      piwik_registration_virtual_page = stub_piwik_idp_registration('LOA1 Corp', recommended: true, loa: 'LEVEL_1')
      stub_piwik_idp_registration('LOA1 Corp', loa: 'LEVEL_1')
      visit '/choose-a-certified-company'

      select_idp_stub_request
      stub_session_idp_authn_request(originating_ip, location, true)
      expect_any_instance_of(ChooseACertifiedCompanyLoa1VariantRadioController).to receive(:select_idp_ajax).and_call_original

      choose '__loa1-entity-id', allow_label_click: true
      click_button 'Continue to the company website'
      expect(page).to have_current_path(location)
      expect(page).to have_content("SAML Request is 'a-saml-request'")
      expect(page).to have_content("relay state is 'a-relay-state'")
      expect(page).to have_content("registration is 'true'")
      expect(select_idp_stub_request).to have_been_made.once
      expect(piwik_registration_virtual_page).to have_been_made.once
    end
  end

  context 'with JS disabled', js: false do
    it 'will redirect the user to the IDP redirect page' do
      visit '/choose-a-certified-company'

      select_idp_stub_request
      stub_session_idp_authn_request(originating_ip, location, false)

      piwik_registration_virtual_page = stub_piwik_idp_registration('LOA1 Corp', recommended: true, loa: 'LEVEL_1')

      choose '__loa1-entity-id', allow_label_click: true
      click_button 'Continue to the company website'

      expect(page).to have_current_path(redirect_to_idp_register_path)
      expect(select_idp_stub_request).to have_been_made.once
      expect(piwik_registration_virtual_page).to have_been_made.once
    end
  end

  context 'shows a validation message when form is invalid' do
    it 'when js is off' do
      visit '/choose-a-certified-company'

      click_button 'Continue to the company website'

      expect(page).to have_current_path(choose_a_certified_company_path)
      expect(page).to have_content 'Select a company'
    end

    it 'when js is on', js: true do
      visit '/choose-a-certified-company'

      click_button 'Continue to the company website'

      expect(page).to have_current_path(choose_a_certified_company_path)
      expect(page).to have_css '#validation-error-message-js', text: 'Select a company'
    end
  end
end
