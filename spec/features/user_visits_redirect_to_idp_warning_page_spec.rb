require 'feature_helper'
require 'api_test_helper'
require 'piwik_test_helper'
require 'i18n'

RSpec.describe 'When the user visits the redirect to IDP warning page' do
  let(:originating_ip) { '<PRINCIPAL IP ADDRESS COULD NOT BE DETERMINED>' }
  let(:encrypted_entity_id) { 'an-encrypted-entity-id' }
  let(:location) { '/test-idp-request-endpoint' }
  let(:selected_evidence) { { phone: %w(mobile_phone smart_phone), documents: %w(passport) } }
  let(:idp_entity_id) { 'http://idcorp.com' }
  let(:given_an_idp_with_no_display_data) {
    page.set_rack_session(
      selected_idp: { entity_id: idp_entity_id, simple_id: 'stub-idp-x' },
      selected_idp_was_recommended: true,
      selected_evidence: selected_evidence,
    )
  }
  let(:given_a_session_with_document_evidence) {
    page.set_rack_session(
      selected_idp: { entity_id: idp_entity_id, simple_id: 'stub-idp-one' },
      selected_idp_was_recommended: true,
      selected_evidence: selected_evidence,
    )
  }
  let(:given_a_session_with_non_recommended_idp) {
    page.set_rack_session(
      selected_idp: { entity_id: idp_entity_id, simple_id: 'stub-idp-one' },
      selected_idp_was_recommended: false,
      selected_evidence: selected_evidence,
    )
  }
  let(:given_a_session_with_no_document_evidence) {
    page.set_rack_session(
      selected_idp: { entity_id: 'http://idpnodocs.com', simple_id: 'stub-idp-no-docs' },
      selected_idp_was_recommended: true,
      selected_evidence: { phone: %w(mobile_phone smart_phone), documents: [] },
    )
  }
  let(:given_a_session_with_non_uk_id_document_evidence) {
    page.set_rack_session(
      selected_idp: { entity_id: 'http://idpwithnonukid.com', simple_id: 'stub-idp-four' },
      selected_idp_was_recommended: true,
      selected_evidence: { phone: %w(mobile_phone smart_phone), documents: %w(non_uk_id_document) },
    )
  }
  let(:select_idp_stub_request) {
    stub_session_select_idp_request(
      encrypted_entity_id,
       'entityId' => idp_entity_id, 'originatingIp' => originating_ip, 'registration' => true
    )
  }

  before(:each) do
    set_session_cookies!
  end

  it 'includes the appropriate feedback source and page title' do
    given_a_session_with_document_evidence
    visit '/redirect-to-idp-warning'

    expect(page).to have_title "You'll now be redirected - GOV.UK Verify - GOV.UK"
    expect_feedback_source_to_be(page, 'REDIRECT_TO_IDP_WARNING_PAGE')
  end

  it 'supports the welsh language' do
    given_a_session_with_document_evidence
    visit '/ailgyfeirio-i-rybudd-idp'

    expect(page).to have_title "Byddwch nawr yn cael eich ailgyfeirio - GOV.UK Verify - GOV.UK"
    expect(page).to have_css 'html[lang=cy]'
  end

  it 'should show the user an error page if the required parameters are missing' do
    stub_transactions_list
    visit '/redirect-to-idp-warning'

    expect(page).to have_content 'something went wrong'
  end

  it 'will render the error page given a session with an IDP that has no display data' do
    given_an_idp_with_no_display_data
    stub_transactions_list

    visit '/redirect-to-idp-warning'

    expect(page).to have_content('Sorry, something went wrong')
  end

  it 'goes to "redirect-to-idp" page on submit' do
    stub_federation
    given_a_session_with_document_evidence

    visit '/redirect-to-idp-warning'

    select_idp_stub_request
    stub_session_idp_authn_request(originating_ip, location, false)

    piwik_registration_virtual_page = stub_piwik_idp_registration('IDCorp', selected_evidence)

    click_button 'Continue to IDCorp'

    expect(page).to have_current_path(redirect_to_idp_path)
    expect(select_idp_stub_request).to have_been_made.once
    expect(piwik_registration_virtual_page).to have_been_made.once
    expect(cookie_value('verify-front-journey-hint')).to_not be_nil
  end

  it 'goes to "redirect-to-idp" page on submit for non-recommended idp' do
    stub_federation
    given_a_session_with_non_recommended_idp

    visit '/redirect-to-idp-warning'

    select_idp_stub_request
    stub_session_idp_authn_request(originating_ip, location, false)

    piwik_registration_virtual_page = stub_piwik_idp_registration('IDCorp', selected_evidence, recommended: false)

    click_button 'Continue to IDCorp'

    expect(page).to have_current_path(redirect_to_idp_path)
    expect(select_idp_stub_request).to have_been_made.once
    expect(piwik_registration_virtual_page).to have_been_made.once
    expect(cookie_value('verify-front-journey-hint')).to_not be_nil
  end

  it 'includes the recommended text when selection is a recommended idp' do
    given_a_session_with_document_evidence
    visit '/redirect-to-idp-warning'

    expect(page).to have_content 'You’ll now verify your identity on IDCorp’s website.'
    expect(page).to_not have_content 'Additional IDP instructions'
  end

  it 'includes the recommended text when selection is a non recommended idp' do
    given_a_session_with_non_recommended_idp
    visit '/redirect-to-idp-warning'

    expect(page).to have_content 'To be verified with IDCorp, you’ll need:'
    within('#requirements') do
      expect(page).to have_content('a UK passport')
      expect(page).to have_content('a UK photocard driving licence')
    end
  end

  it 'includes specific IDP text and link to the other ways when user has no documents' do
    page.set_rack_session(transaction_simple_id: 'test-rp')
    given_a_session_with_no_document_evidence
    visit '/redirect-to-idp-warning'

    expect(page).to have_content 'You’ll now verify your identity on No Docs IDP’s website.'
    expect(page).to have_content 'Additional IDP Instructions'
    expect(page).to have_link 'other ways to register for an identity profile', href: other_ways_to_access_service_path
  end

  it 'includes specific IDP text and link to the other ways when user has only foreign id document' do
    page.set_rack_session(transaction_simple_id: 'test-rp')
    given_a_session_with_non_uk_id_document_evidence
    visit '/redirect-to-idp-warning'

    expect(page).to have_content 'You’ll now verify your identity on Best ID’s website.'
    expect(page).to have_content 'Additional IDP Instructions'
    expect(page).to have_link 'other ways to register for an identity profile', href: other_ways_to_access_service_path
  end

  context 'with JS enabled', js: true do
    it 'will redirect the user to the IDP on Continue' do
      piwik_registration_virtual_page = stub_piwik_idp_registration('IDCorp', selected_evidence)
      stub_piwik_idp_selection_list('IDCorp')
      stub_federation
      given_a_session_with_document_evidence
      visit '/redirect-to-idp-warning'

      select_idp_stub_request
      stub_session_idp_authn_request(originating_ip, location, true)
      expect_any_instance_of(RedirectToIdpWarningController).to receive(:continue_ajax).and_call_original

      click_button 'Continue to IDCorp'

      expect(select_idp_stub_request).to have_been_made.once
      expect(piwik_registration_virtual_page).to have_been_made.once
      expect(cookie_value('verify-front-journey-hint')).to_not be_nil
      expect(page).to have_current_path(location)
      expect(page).to have_content("SAML Request is 'a-saml-request'")
      expect(page).to have_content("relay state is 'a-relay-state'")
      expect(page).to have_content("registration is 'true'")
    end
  end
end
