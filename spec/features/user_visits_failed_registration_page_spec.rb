require "feature_helper"
require "api_test_helper"

describe "When the user visits the failed registration page and" do
  CONTINUE_ON_FAILED_REGISTRATION_RP = "test-rp-with-continue-on-fail".freeze
  DONT_CONTINUE_ON_FAILED_REGISTRATION_RP = "test-rp".freeze
  CUSTOM_FAIL_PAGE_RP = "test-rp-no-demo".freeze

  before(:each) do
    set_session_and_session_cookies!
    stub_api_idp_list_for_registration
    set_selected_idp_in_session(entity_id: "http://idcorp.com", simple_id: "stub-idp-one")
  end

  context "relying party is allowed to continue on fail then page rendered" do
    before(:each) do
      page.set_rack_session(transaction_simple_id: CONTINUE_ON_FAILED_REGISTRATION_RP)
    end

    it "includes expected content for LOA2 journey" do
      set_loa_in_session("LEVEL_2")
      visit "/failed-registration"

      expect_page_to_have_main_content_continue_on_fail
      expect(page).to have_content t("hub.failed_registration.continue_text", rp_name: "Test RP")
      expect(page).to have_link t("navigation.continue"), href: redirect_to_service_error_path
      expect(page).to have_link t("hub.failed_registration.try_another_company"), href: choose_a_certified_company_path
    end

    it "includes expected content for LOA1 journey" do
      set_loa_in_session("LEVEL_1")
      visit "/failed-registration"

      expect_page_to_have_main_content_continue_on_fail
      expect(page).to have_content t("hub.failed_registration.continue_text", rp_name: "Test RP")
      expect(page).to have_link t("navigation.continue"), href: redirect_to_service_error_path
      expect(page).to have_link t("hub.failed_registration.try_another_company"), href: choose_a_certified_company_path
    end
  end

  context "relying party is not allowed to continue on fail" do
    before(:each) do
      page.set_rack_session(transaction_simple_id: DONT_CONTINUE_ON_FAILED_REGISTRATION_RP)
    end
    context "there are more IDPs to try" do
      before(:each) do
        session = default_session
        session[:selected_answers] = {
          documents: { has_driving_license: true, has_valid_passport: true, has_credit_card: true },
          device_type: { device_type_other: true },
       }
        page.set_rack_session(session)
      end
      it "includes expected content when LOA2 journey" do
        set_loa_in_session("LEVEL_2")
        visit "/failed-registration"

        expect_page_to_have_main_content_non_continue
        expect(page).to have_content t("hub.failed_registration.remaining_idps.different_way",
                                       service: "test GOV.UK Verify user journeys")
        expect(page).to have_link t("hub.failed_registration.remaining_idps.link_text"), href: choose_a_certified_company_path
      end

      it "includes expected content when LOA1 journey" do
        set_loa_in_session("LEVEL_1")
        stub_api_idp_list_for_registration(default_idps, "LEVEL_1")
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
      set_loa_in_session("LEVEL_2")
      visit "/failed-registration"
      expect_page_to_have_main_content_non_continue_for_no_idps

      session = default_session
      session[:selected_answers] = {
          documents: { has_driving_license: true, has_valid_passport: true, has_credit_card: true },
          device_type: { device_type_other: true },
      }
      set_session! session
      set_selected_idp_in_session(entity_id: "http://idcorp.com", simple_id: "stub-idp-one")
      page.set_rack_session(transaction_simple_id: DONT_CONTINUE_ON_FAILED_REGISTRATION_RP)
      set_loa_in_session("LEVEL_2")
      visit "/failed-registration"

      expect_page_to_have_main_content_non_continue
    end
  end

  context "relying party is not allowed to continue on fail and is custom fail rp" do
    before(:each) do
      page.set_rack_session(transaction_simple_id: CUSTOM_FAIL_PAGE_RP)
    end

    it "includes expected content when custom fail LOA2 journey in welsh" do
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

  def expect_page_to_have_main_content_continue_on_fail
    expect_feedback_source_to_be(page, "FAILED_REGISTRATION_PAGE", "/failed-registration")
    expect(page).to have_title t("hub.failed_registration.heading", idp_name: "IDCorp")
    expect(page).to have_content t("hub.failed_registration.heading", idp_name: "IDCorp")
    expect(page).to have_content t("hub.failed_registration.contact_details_intro", idp_name: "IDCorp")
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
