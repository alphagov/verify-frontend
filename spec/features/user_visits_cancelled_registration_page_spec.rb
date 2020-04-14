require "feature_helper"
require "api_test_helper"
require "piwik_test_helper"

RSpec.describe "When user visits cancelled registration page" do
  before :each do
    set_session_and_session_cookies!
    page.set_rack_session transaction_simple_id: "test-rp"
    set_selected_idp_in_session(entity_id: "http://idcorp.com", simple_id: "stub-idp-one")
  end

  it "the page is rendered with the correct content for LOA2 journey" do
    set_loa_in_session("LEVEL_2")

    visit("/cancelled-registration")

    expect(page).to have_title t("hub.cancelled_registration.title")
    expect(page).to have_link t("hub.cancelled_registration.send_feedback")
    expect(page).to have_link t("hub.cancelled_registration.about_choosing_a_company"), href: about_choosing_a_company_path
  end

  it "the page is rendered with the correct content for LOA1 journey" do
    set_loa_in_session("LEVEL_1")

    visit("/cancelled-registration")

    expect(page).to have_title t("hub.cancelled_registration.title")
    expect(page).to have_link t("hub.cancelled_registration.send_feedback")
    expect(page).to have_link t("hub.cancelled_registration.about_choosing_a_company"), href: about_choosing_a_company_path
  end
end
