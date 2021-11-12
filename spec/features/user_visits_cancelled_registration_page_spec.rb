require "feature_helper"
require "api_test_helper"
require "piwik_test_helper"

RSpec.describe "When user visits cancelled registration page" do
  let(:identity_provider_display_decorator) { double(:IdentityProviderDisplayDecorator) }
  before :each do
    stub_request(:get, CONFIG.config_api_host + "/config/transactions/enabled")
    set_session_and_session_cookies!
    page.set_rack_session transaction_simple_id: "test-rp"
    set_selected_idp_in_session(entity_id: "http://idcorp.com", simple_id: "stub-idp-one")
  end

  context "If there is more than one IDP" do
    it "the page is rendered with the correct content for LOA2 journey" do
      set_loa_in_session("LEVEL_2")
      stub_api_idp_list_for_registration(loa: "LEVEL_2")

      visit("/cancelled-registration")

      expect(page).not_to have_link t("feedback_link.feedback_form")
      expect(page).to have_title t("hub.cancelled_registration.heading", idp_name: "IDCorp")
      expect(page).to have_content t("hub.cancelled_registration.try_another_summary")
      expect(page).to have_link t("hub.cancelled_registration.send_feedback")
      expect(page).to have_link t("hub.cancelled_registration.about_choosing_a_company"), href: about_choosing_a_company_path
    end

    it "the page is rendered with the correct content for LOA1 journey" do
      set_loa_in_session("LEVEL_1")
      stub_api_idp_list_for_registration(loa: "LEVEL_1")

      visit("/cancelled-registration")

      expect(page).not_to have_link t("feedback_link.feedback_form")
      expect(page).to have_title t("hub.cancelled_registration.heading", idp_name: "IDCorp")
      expect(page).to have_content t("hub.cancelled_registration.try_another_summary")
      expect(page).to have_link t("hub.cancelled_registration.send_feedback")
      expect(page).to have_link t("hub.cancelled_registration.about_choosing_a_company"), href: about_choosing_a_company_path
    end
  end

  context "If there is more than one IDP" do
    it "the page won't have try another idp" do
      set_loa_in_session("LEVEL_2")
      stub_api_idp_list_for_registration([{ "simpleId" => "stub-idp-loa1", "entityId" => "http://idcorp-loa1.com", "levelsOfAssurance" => %w(LEVEL_1 LEVEL_2), "enabled" => true }])

      visit("/cancelled-registration")

      expect(page).not_to have_link t("feedback_link.feedback_form")
      expect(page).to have_title t("hub.cancelled_registration.heading", idp_name: "IDCorp")
      expect(page).not_to have_content t("hub.cancelled_registration.try_another_summary")
      expect(page).to have_link t("hub.cancelled_registration.send_feedback")
      expect(page).not_to have_link t("hub.cancelled_registration.about_choosing_a_company"), href: about_choosing_a_company_path
    end
  end
end
