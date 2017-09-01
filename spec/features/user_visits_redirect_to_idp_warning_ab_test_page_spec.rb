require 'feature_helper'
require 'api_test_helper'
require 'piwik_test_helper'

RSpec.describe 'When the user visits the redirect to IDP warning page' do
  let(:originating_ip) { '<PRINCIPAL IP ADDRESS COULD NOT BE DETERMINED>' }
  let(:encrypted_entity_id) { 'an-encrypted-entity-id' }
  let(:location) { '/test-idp-request-endpoint' }
  let(:selected_answers) { { 'phone' => { 'mobile_phone' => true, 'smart_phone' => true }, 'documents' => { 'passport' => true } } }
  let(:idp_entity_id) { 'http://idcorp.com' }
  let(:given_a_session_with_document_answers) {
    page.set_rack_session(
      selected_idp: { entity_id: idp_entity_id, simple_id: 'stub-idp-one' },
      selected_idp_was_recommended: true,
      selected_answers: selected_answers,
    )
  }
  let(:select_idp_stub_request) {
    stub_session_select_idp_request(
      encrypted_entity_id,
       'entityId' => idp_entity_id, 'originatingIp' => originating_ip, 'registration' => true
    )
  }

  context 'with idp_warning_variant_heading_account AB test cookie' do
    it 'will have a header mentioning an IDP account' do
      set_session_and_ab_session_cookies!('idp_warning' => 'idp_warning_variant_heading_account')
      stub_piwik_idp_registration('IDCorp')
      given_a_session_with_document_answers
      visit '/redirect-to-idp-warning'

      select_idp_stub_request
      stub_session_idp_authn_request(originating_ip, location, true)

      expect(page).to have_css('h1', text: 'Create your IDCorp identity account')
      expect(page).to have_css('button', text: 'Continue to the IDCorp website')
    end
  end

  context 'with idp_warning_variant_heading_website AB test cookie' do
    it 'will have a header mentioning an IDP account' do
      set_session_and_ab_session_cookies!('idp_warning' => 'idp_warning_variant_heading_website')
      stub_piwik_idp_registration('IDCorp')
      given_a_session_with_document_answers
      visit '/redirect-to-idp-warning'

      select_idp_stub_request
      stub_session_idp_authn_request(originating_ip, location, true)

      expect(page).to have_css('h1', text: 'Continue to the IDCorp website')
      expect(page).to have_css('button', text: 'Create your IDCorp identity account')
    end
  end
end
