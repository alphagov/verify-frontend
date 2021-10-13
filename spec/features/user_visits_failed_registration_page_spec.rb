require "feature_helper"
require "api_test_helper"

describe "When the user visits the failed registration page and" do
  DEFAULT_FAILED_REGISTRATION_PAGE_RP = "test-rp".freeze
  CUSTOM_FAILED_REGISTRATION_PAGE_RP = "test-rp-no-demo".freeze

  before(:each) do
    set_session_and_session_cookies!
    stub_api_idp_list_for_registration
    set_selected_idp_in_session(entity_id: "http://idcorp.com", simple_id: "stub-idp-one")
  end

  context "relying party uses standard failed registration page" do
    before(:each) do
      page.set_rack_session(transaction_simple_id: DEFAULT_FAILED_REGISTRATION_PAGE_RP)
    end

    context "there are more IDPs to try" do
      it "includes expected content for an LOA2 journey" do
        set_loa_in_session("LEVEL_2")
        visit "/failed-registration"

        expect_page_to_have_main_content_non_continue
        expect(page).to have_content t("hub.failed_registration.remaining_idps.different_way",
                                       service: "test GOV.UK Verify user journeys")
        expect(page).to have_link t("hub.failed_registration.remaining_idps.link_text"), href: choose_a_certified_company_path
      end

      it "includes expected content for an LOA1 journey" do
        set_loa_in_session("LEVEL_1")
        stub_api_idp_list_for_registration(loa: "LEVEL_1")
        visit "/failed-registration"

        expect_page_to_have_main_content_non_continue
        expect(page).to have_content t("hub.failed_registration.remaining_idps.different_way",
                                       service: "test GOV.UK Verify user journeys")
        expect(page).to have_link t("hub.failed_registration.remaining_idps.link_text"), href: choose_a_certified_company_path
      end
    end

    context "there are no more IDPs to try" do
      it "includes expected content when LOA2 journey" do
        set_loa_in_session("LEVEL_2")
        stub_api_idp_list_for_registration([])
        visit "/failed-registration"

        expect_page_to_have_main_content_non_continue_for_no_idps
        expect(page).to have_content t("hub.failed_registration.last_idp.different_way",
                                       service: "test GOV.UK Verify user journeys")
        expect(page).not_to have_link t("hub.failed_registration.remaining_idps.link_text"), href: choose_a_certified_company_path
      end

      it "includes expected content when LOA1 journey" do
        set_loa_in_session("LEVEL_1")
        stub_api_idp_list_for_registration([], "LEVEL_1")
        visit "/failed-registration"

        expect_page_to_have_main_content_non_continue_for_no_idps
        expect(page).to have_content t("hub.failed_registration.last_idp.different_way",
                                       service: "test GOV.UK Verify user journeys")
        expect(page).not_to have_link t("hub.failed_registration.start_again"), href: choose_a_certified_company_path
      end
    end

    it "starts a new session and IDPs are available again" do
      idp = { simpleId: "stub-idp-two", entityId: "http://idcorp.com", levelsOfAssurance: %w(LEVEL_2) }

      stub_api_idp_list_for_registration([])
      set_loa_in_session("LEVEL_2")
      visit "/failed-registration"
      expect_page_to_have_main_content_non_continue_for_no_idps

      stub_api_idp_list_for_registration([idp])
      set_selected_idp_in_session(entity_id: "http://idcorp.com", simple_id: "stub-idp-one")
      page.set_rack_session(transaction_simple_id: DEFAULT_FAILED_REGISTRATION_PAGE_RP)
      set_loa_in_session("LEVEL_2")
      visit "/failed-registration"

      expect_page_to_have_main_content_non_continue
    end
  end

  context "relying party has a custom failed registration page" do
    before(:each) do
      page.set_rack_session(transaction_simple_id: CUSTOM_FAILED_REGISTRATION_PAGE_RP)
    end

    it "includes expected content when custom fail LOA2 journey in Welsh" do
      set_loa_in_session("LEVEL_2")
      visit "/cofrestru-wedi-methu"
      expect(page).to have_content "This is a custom fail page in welsh."
      expect(page).to have_content "Custom text to be provided by RP."
      expect(page).to have_link t("hub.failed_registration.start_again", locale: :cy), href: choose_a_certified_company_cy_path
    end

    it "includes expected content when custom fail LOA2 journey" do
      set_loa_in_session("LEVEL_2")
      visit "/failed-registration"
      expect(page).to have_content "This is a custom fail page."
      expect(page).to have_content "Custom text to be provided by RP."
      expect(page).to have_link t("hub.failed_registration.start_again"), href: choose_a_certified_company_path
    end
  end

  def expect_page_to_have_main_content_non_continue
    expect_feedback_source_to_be(page, "FAILED_REGISTRATION_PAGE", "/failed-registration")
    expect(page).to have_title t("hub.failed_registration.heading", idp_name: "IDCorp")
    expect(page).to have_content t("hub.failed_registration.heading", idp_name: "IDCorp")
    expect(page).to have_content t("hub.failed_registration.remaining_idps.different_way", service: "test GOV.UK Verify user journeys")
  end

  def expect_page_to_have_main_content_non_continue_for_no_idps
    expect_feedback_source_to_be(page, "FAILED_REGISTRATION_PAGE", "/failed-registration")
    expect(page).to have_title t("hub.failed_registration.heading", idp_name: "IDCorp")
    expect(page).to have_content t("hub.failed_registration.heading", idp_name: "IDCorp")
    expect(page).to have_content t("hub.failed_registration.last_idp.different_way", service: "test GOV.UK Verify user journeys")
  end
end
