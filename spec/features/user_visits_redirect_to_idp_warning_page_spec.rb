require "feature_helper"
require "api_test_helper"
require "piwik_test_helper"

RSpec.describe "When the user visits the redirect to IDP warning page" do
  let(:originating_ip) { "<PRINCIPAL IP ADDRESS COULD NOT BE DETERMINED>" }
  let(:encrypted_entity_id) { "an-encrypted-entity-id" }
  let(:location) { "/test-idp-request-endpoint" }
  let(:selected_answers) { { "phone" => { "mobile_phone" => true, "smart_phone" => true }, "documents" => { "passport" => true } } }
  let(:idp_entity_id) { "http://idcorp.com" }
  let(:given_an_idp_with_no_display_data) {
    set_selected_idp_in_session(entity_id: idp_entity_id, simple_id: "stub-idp-x")
    page.set_rack_session(
      selected_idp_was_recommended: true,
      selected_answers: selected_answers,
    )
  }
  let(:given_a_session_with_document_answers) {
    set_selected_idp_in_session(entity_id: idp_entity_id, simple_id: "stub-idp-one")
    page.set_rack_session(
      selected_idp_was_recommended: true,
      selected_answers: selected_answers,
    )
  }
  let(:given_a_session_with_a_hints_disabled_idp) {
    set_selected_idp_in_session(entity_id: idp_entity_id, simple_id: "stub-idp-two")
    page.set_rack_session(
      selected_idp_was_recommended: true,
      selected_answers: selected_answers,
    )
  }
  let(:given_a_session_with_non_recommended_idp) {
    set_selected_idp_in_session(entity_id: idp_entity_id, simple_id: "stub-idp-one")
    page.set_rack_session(
      selected_idp_was_recommended: false,
      selected_answers: selected_answers,
    )
  }
  let(:given_a_session_with_no_document_answers) {
    set_selected_idp_in_session(entity_id: "http://idpnodocs.com", simple_id: "stub-idp-no-docs")
    page.set_rack_session(
      selected_idp_was_recommended: true,
      selected_answers: { phone: { mobile_phone: true, smart_phone: true }, documents: {} },
    )
  }
  let(:given_a_session_with_non_uk_id_document_answers) {
    set_selected_idp_in_session(entity_id: "http://idpwithnonukid.com", simple_id: "stub-idp-four")
    page.set_rack_session(
      selected_idp_was_recommended: true,
      selected_answers: { phone: { mobile_phone: true, smart_phone: true }, documents: { non_uk_id_document: true } },
    )
  }
  let(:select_idp_stub_request) {
    stub_session_select_idp_request(
      encrypted_entity_id,
      PolicyEndpoints::PARAM_SELECTED_ENTITY_ID => idp_entity_id, PolicyEndpoints::PARAM_PRINCIPAL_IP => originating_ip,
      PolicyEndpoints::PARAM_REGISTRATION => true, PolicyEndpoints::PARAM_REQUESTED_LOA => "LEVEL_2",
      PolicyEndpoints::PARAM_ANALYTICS_SESSION_ID => piwik_session_id, PolicyEndpoints::PARAM_JOURNEY_TYPE => nil,
      PolicyEndpoints::PARAM_VARIANT => nil
    )
  }

  before(:each) do
    stub_api_idp_list_for_registration
    session = default_session.merge(user_segments: %w(test-segment))
    set_session_and_session_cookies!(cookie_hash: create_cookie_hash_with_piwik_session, session: session)
    allow_any_instance_of(UserCookiesPartialController)
      .to receive(:ab_test_with_alternative_name).and_return(nil)
  end

  it "includes the appropriate feedback source and page title" do
    given_a_session_with_document_answers
    visit "/redirect-to-idp-warning"

    expect(page).to have_title t("hub.redirect_to_idp_warning.title")
    expect_feedback_source_to_be(page, "REDIRECT_TO_IDP_WARNING_PAGE", "/redirect-to-idp-warning")
  end

  it "supports the welsh language" do
    given_a_session_with_document_answers
    visit "/ailgyfeirio-i-rybudd-idp"

    expect(page).to have_title t("hub.redirect_to_idp_warning.title", locale: :cy)
    expect(page).to have_css "html[lang=cy]"
  end

  it "should show the user an error page if the required parameters are missing" do
    stub_transactions_list
    visit "/redirect-to-idp-warning"

    expect(page).to have_content t("errors.something_went_wrong.heading")
  end

  it "will render the error page given a session with an IDP that has no display data" do
    given_an_idp_with_no_display_data
    stub_transactions_list

    visit "/redirect-to-idp-warning"

    expect(page).to have_content t("errors.something_went_wrong.heading")
  end

  it "goes to 'redirect-to-idp' page on submit" do
    given_a_session_with_document_answers

    visit "/redirect-to-idp-warning"

    select_idp_stub_request
    stub_session_idp_authn_request(originating_ip, location, false)

    piwik_registration_virtual_page = stub_piwik_idp_registration(
      "IDCorp",
      selected_answers: selected_answers,
      recommended: true,
      segments: %w(test-segment),
    )

    click_button t("hub.redirect_to_idp_warning.continue_website", display_name: t("idps.stub-idp-one.name"))

    expect(page).to have_current_path(redirect_to_idp_register_path)
    expect(select_idp_stub_request).to have_been_made.once
    expect(piwik_registration_virtual_page).to have_been_made.once
    expect(cookie_value("verify-front-journey-hint")).to_not be_nil
  end

  it "goes to 'redirect-to-idp' page on submit for non-recommended idp" do
    given_a_session_with_non_recommended_idp

    visit "/redirect-to-idp-warning"

    select_idp_stub_request
    stub_session_idp_authn_request(originating_ip, location, false)

    piwik_registration_virtual_page = stub_piwik_idp_registration("IDCorp", selected_answers: selected_answers, segments: %w(test-segment))

    click_button t("hub.redirect_to_idp_warning.continue_website", display_name: t("idps.stub-idp-one.name"))

    expect(page).to have_current_path(redirect_to_idp_register_path)
    expect(select_idp_stub_request).to have_been_made.once
    expect(piwik_registration_virtual_page).to have_been_made.once
    expect(cookie_value("verify-front-journey-hint")).to_not be_nil
  end

  it "includes the recommended text when selection is a recommended idp" do
    given_a_session_with_document_answers
    visit "/redirect-to-idp-warning"

    expect(page.body).to have_content t("hub.redirect_to_idp_warning.continue_website", display_name: "IDCorp")
    expect(page.body).to include t("hub.redirect_to_idp_warning.identity_account_use_html", display_name: "IDCorp")
  end

  context "with JS enabled", js: true do
    it "will redirect the user to the IDP on Continue" do
      piwik_registration_virtual_page = stub_piwik_idp_registration("IDCorp", selected_answers: selected_answers, recommended: true, segments: %w(test-segment))
      stub_piwik_idp_registration("IDCorp")
      given_a_session_with_document_answers
      visit "/redirect-to-idp-warning"

      select_idp_stub_request
      stub_session_idp_authn_request(originating_ip, location, true)
      expect_any_instance_of(RedirectToIdpWarningController).to receive(:continue_ajax).and_call_original

      click_button t("hub.redirect_to_idp_warning.continue_website", display_name: t("idps.stub-idp-one.name"))
      expect(page).to have_current_path(location)
      expect(page).to have_content("SAML Request is 'a-saml-request'")
      expect(page).to have_content("relay state is 'a-relay-state'")
      expect(page).to have_content("registration is 'true'")
      expect(page).to have_content("hints are 'has_mobile, has_apps, has_ukpassport'")
      expect(page).to have_content("language hint was 'en'")
      expect(select_idp_stub_request).to have_been_made.once
      expect(piwik_registration_virtual_page).to have_been_made.once
      expect(cookie_value("verify-front-journey-hint")).to_not be_nil
    end

    it "will redirect the user to the IDP without sending hints when they are disabled" do
      stub_piwik_idp_registration("IDCorp")
      given_a_session_with_a_hints_disabled_idp
      visit "/redirect-to-idp-warning"

      select_idp_stub_request
      stub_session_idp_authn_request(originating_ip, location, true)
      expect_any_instance_of(RedirectToIdpWarningController).to receive(:continue_ajax).and_call_original

      click_button t("hub.redirect_to_idp_warning.continue_website", display_name: t("idps.stub-idp-two.name"))
      expect(page).to have_current_path(location)
      expect(page).to have_content("hints are ''")
      expect(page).to have_content("language hint was ''")
    end
  end
end
