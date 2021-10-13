require "feature_helper"
require "api_test_helper"
require "piwik_test_helper"

RSpec.describe "When the user visits the continue to your IDP page" do
  let(:encrypted_entity_id) { "an-encrypted-entity-id" }
  let(:idp_entity_id) { "http://idcorp.com" }
  let(:idp_display_name) { "IDCorp" }
  let(:stub_select_idp_request) {
    stub_session_select_idp_request(
      encrypted_entity_id,
      PolicyEndpoints::PARAM_SELECTED_ENTITY_ID => idp_entity_id,
      PolicyEndpoints::PARAM_PRINCIPAL_IP => ApiTestHelper::ORIGINATING_IP,
      PolicyEndpoints::PARAM_REGISTRATION => false,
      PolicyEndpoints::PARAM_REQUESTED_LOA => "LEVEL_2",
      PolicyEndpoints::PARAM_PERSISTENT_SESSION_ID => instance_of(String), # no longer comes from matomo
      PolicyEndpoints::PARAM_JOURNEY_TYPE => "single-idp",
      PolicyEndpoints::PARAM_VARIANT => nil,
    )
  }
  let(:set_single_idp_journey_cookie) {
    visit "/test-single-idp-journey"
    click_button "initiate-single-idp-post"
  }
  context "javascript disabled" do
    before(:each) do
      set_session_and_session_cookies!(cookie_hash: create_cookie_hash_with_piwik_session)
      stub_transactions_for_single_idp_list
      stub_api_idp_list_for_single_idp_journey
    end

    it "includes the appropriate feedback source, page title and piwik custom variable" do
      set_single_idp_journey_cookie
      visit continue_to_your_idp_path

      expect(page).to have_current_path(continue_to_your_idp_path)
      expect(page).to have_title t("hub.single_idp_journey.heading", display_name: idp_display_name)
      expect_feedback_source_to_be(page, "CONTINUE_TO_YOUR_IDP_PAGE", continue_to_your_idp_path)
      piwik_custom_variable_single_idp_journey = '{"index":3,"name":"JOURNEY_TYPE","value":"SINGLE_IDP","scope":"visit"}'
      expect(page).to have_content(piwik_custom_variable_single_idp_journey)
    end

    it "supports the welsh language" do
      set_single_idp_journey_cookie
      visit continue_to_your_idp_cy_path

      expect(page).to have_title t("hub.single_idp_journey.heading", locale: :cy, display_name: "Welsh IDCorp")
      expect(page).to have_css "html[lang=cy]"
    end

    it "should show the user the start page if the cookie is missing" do
      visit continue_to_your_idp_path

      expect(page).to have_content t("hub.start.heading")
    end

    it "renders the redirect-to-idp page on submit" do
      set_single_idp_journey_cookie
      stub_select_idp_request
      stub_session_idp_authn_request

      visit continue_to_your_idp_path
      click_button t("hub.single_idp_journey.continue_button", display_name: idp_display_name)

      expect(page).to have_current_path(redirect_to_single_idp_path)
      expect(stub_select_idp_request).to have_been_made.once
      expect(stub_piwik_request("action_name" => "Single IDP selected - #{idp_display_name}")).to have_been_made.once
    end
  end

  context "with JS enabled", js: true do
    def single_idp_session
      {
        transaction_simple_id: "test-rp-noc3",
        start_time: start_time_in_millis,
        verify_session_id: default_session_id,
        requested_loa: "LEVEL_2",
        transaction_entity_id: "some-other-entity-id",
      }
    end

    before(:each) do
      set_session_and_session_cookies!(cookie_hash: create_cookie_hash_with_piwik_session, session: single_idp_session)
      stub_transactions_for_single_idp_list(Capybara.current_session.server.port)
      stub_api_idp_list_for_single_idp_journey("some-other-entity-id")
      visit "/test-single-idp-journey"
      # javascript driver needs a redirect to a real page
      fill_in("serviceId", with: "some-other-entity-id")
      click_button "initiate-single-idp-post"
    end

    it "will redirect the user to the IDP on Continue" do
      visit continue_to_your_idp_path
      stub_select_idp_request
      stub_session_idp_authn_request
      expect_any_instance_of(SingleIdpJourneyController).to receive(:continue_ajax).and_call_original

      click_button t("hub.single_idp_journey.continue_button", display_name: idp_display_name)
      expect(stub_piwik_request("action_name" => "Single IDP selected - #{idp_display_name}")).to have_been_made.once
      expect(page).to have_current_path(ApiTestHelper::IDP_LOCATION)
      expect(page).to have_content("SAML Request is 'a-saml-request'")
      expect(page).to have_content("relay state is 'a-relay-state'")
      expect(page).to have_content("registration is 'false'")
      expect(page).to have_content("single IDP journey uuid is ")
      expect(stub_select_idp_request).to have_been_made.once
    end
  end
end
