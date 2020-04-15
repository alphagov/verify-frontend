require "feature_helper"
require "api_test_helper"
require "piwik_test_helper"

RSpec.describe "When the user visits the resume registration page and " do
  let(:idp_display_name) { "IDCorp" }
  let(:service_name) { "test GOV.UK Verify user journeys" }
  let(:rp_entity_id) { "http://www.test-rp.gov.uk/SAML2/MD" }
  let(:originating_ip) { "<PRINCIPAL IP ADDRESS COULD NOT BE DETERMINED>" }
  let(:idp_entity_id) { "http://idcorp.com" }
  let(:encrypted_entity_id) { "an-encrypted-entity-id" }
  let(:location) { "/test-idp-request-endpoint" }

  let(:select_idp_stub_request) {
    stub_session_select_idp_request(
      encrypted_entity_id,
      PolicyEndpoints::PARAM_SELECTED_ENTITY_ID => idp_entity_id, PolicyEndpoints::PARAM_PRINCIPAL_IP => originating_ip,
      PolicyEndpoints::PARAM_REGISTRATION => false, PolicyEndpoints::PARAM_REQUESTED_LOA => "LEVEL_2",
      PolicyEndpoints::PARAM_ANALYTICS_SESSION_ID => piwik_session_id, PolicyEndpoints::PARAM_JOURNEY_TYPE => "resuming",
      PolicyEndpoints::PARAM_VARIANT => nil
    )
  }

  before(:each) do
    set_session_and_session_cookies!(cookie_hash: create_cookie_hash_with_piwik_session)
    stub_api_idp_list_for_registration
    stub_api_idp_list_for_sign_in
    set_selected_idp_in_session(entity_id: idp_entity_id, simple_id: "stub-idp-one")
    stub_translations
    stub_transaction_details
    allow_any_instance_of(UserCookiesPartialController)
      .to receive(:ab_test_with_alternative_name).and_return(nil)
  end

  context "has a cookie containing a PENDING state and valid IDP identifiers" do
    it "displays correct text and button" do
      set_journey_hint_cookie(idp_entity_id, "PENDING", "en", rp_entity_id)
      visit "/resume-registration"

      expect(page).to have_content t("hub.paused_registration.resume.intro", service_name: service_name, display_name: idp_display_name)
      expect(page).to have_content t("hub.paused_registration.resume.heading", display_name: idp_display_name)
      expect(page).to have_button t("hub.paused_registration.resume.continue", display_name: idp_display_name)
      expect(page).to have_content t("hub.paused_registration.resume.alternative_other_ways", service_name: service_name)

      piwik_custom_variable_resuming_journey = '{"index":3,"name":"JOURNEY_TYPE","value":"RESUMING","scope":"visit"}'
      expect(page).to have_content(piwik_custom_variable_resuming_journey)
    end
  end

  context "has a cookie containing a non pending state and a RESUMELINK section with a valid IDP " do
    it "displays correct text and button" do
      set_journey_hint_cookie(idp_entity_id, "SUCCESS", "en", rp_entity_id, "stub-idp-one")
      visit "/resume-registration"

      expect(page).to have_content t("hub.paused_registration.resume.intro", service_name: service_name, display_name: idp_display_name)
      expect(page).to have_content t("hub.paused_registration.resume.heading", display_name: idp_display_name)
      expect(page).to have_button t("hub.paused_registration.resume.continue", display_name: idp_display_name)
      expect(page).to have_content t("hub.paused_registration.resume.alternative_other_ways", service_name: service_name)

      piwik_custom_variable_resuming_journey = '{"index":3,"name":"JOURNEY_TYPE","value":"RESUMING","scope":"visit"}'
      expect(page).to have_content(piwik_custom_variable_resuming_journey)
    end
  end

  context "has a cookie containing a pending state for a different IDP and a RESUMELINK link section with a valid IDP " do
    it "displays correct text and button for RESUMELINK IDP" do
      set_journey_hint_cookie("a-different-entity-id", "PENDING", "en", rp_entity_id, "stub-idp-one")
      visit "/resume-registration"

      expect(page).to have_content t("hub.paused_registration.resume.intro", service_name: service_name, display_name: idp_display_name)
      expect(page).to have_content t("hub.paused_registration.resume.heading", display_name: idp_display_name)
      expect(page).to have_button t("hub.paused_registration.resume.continue", display_name: idp_display_name)
      expect(page).to have_content t("hub.paused_registration.resume.alternative_other_ways", service_name: service_name)

      piwik_custom_variable_resuming_journey = '{"index":3,"name":"JOURNEY_TYPE","value":"RESUMING","scope":"visit"}'
      expect(page).to have_content(piwik_custom_variable_resuming_journey)
    end
  end

  context "clicks continue to IDP with JS disabled" do
    it 'goes to "redirect-to-idp" page on submit' do
      set_journey_hint_cookie(idp_entity_id, "PENDING", "en", rp_entity_id)
      visit "/resume-registration"
      select_idp_stub_request
      stub_session_idp_authn_request(originating_ip, location, false)

      click_button t("hub.paused_registration.resume.continue", display_name: idp_display_name)

      expect(page).to have_current_path(redirect_to_idp_resume_path)
      expect(select_idp_stub_request).to have_been_made.once
      expect(stub_piwik_request("action_name" => "Resume - #{idp_display_name}")).to have_been_made.once
    end
  end

  context "clicks continue to IDP with JS enabled", js: true do
    it "will redirect the user to the IDP on Continue" do
      set_journey_hint_cookie(idp_entity_id, "PENDING", "en", rp_entity_id)
      visit "/resume-registration"
      select_idp_stub_request
      stub_session_idp_authn_request(originating_ip, location, false)
      expect_any_instance_of(PausedRegistrationController).to receive(:resume_with_idp_ajax).and_call_original

      click_button t("hub.paused_registration.resume.continue", display_name: idp_display_name)
      expect(stub_piwik_request("action_name" => "Resume - #{idp_display_name}")).to have_been_made.once
      expect(page).to have_current_path(location)
      expect(page).to have_content("SAML Request is 'a-saml-request'")
      expect(page).to have_content("relay state is 'a-relay-state'")
      expect(page).to have_content("registration is 'false'")
      expect(page).to have_content("language hint was 'en'")
      expect(select_idp_stub_request).to have_been_made.once
    end
  end
end
