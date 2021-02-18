require "feature_helper"
require "api_test_helper"

RSpec.describe "When the user visits the choose a country page" do
  let(:originating_ip) { "<PRINCIPAL IP ADDRESS COULD NOT BE DETERMINED>" }
  before(:each) do
    set_session_and_session_cookies!
    stub_api_idp_list_for_registration
    stub_transactions_list
    stub_countries_list
  end

  def no_eidas_session
    "no-eidas-session"
  end

  def given_a_session_supporting_eidas
    page.set_rack_session transaction_supports_eidas: true
  end

  def given_a_session_not_supporting_eidas
    page.set_rack_session(
      verify_session_id: no_eidas_session,
      transaction_supports_eidas: false,
    )
  end

  def then_im_at_the_interstitial_page(locale = "en")
    expect(page).to have_current_path("/#{t('routes.redirect_to_country', locale: locale)}")
    expect(page).to have_title t("hub.redirect_to_country.heading")
    expect(page).to have_content t("hub.redirect_to_country.heading")
    expect(page).to have_content t("hub.redirect_to_country.description")
    expect(page).to have_css("input[id=SAMLRequest]", visible: false)
    expect(find("input[id=SAMLRequest]", visible: false).value).to_not be_empty

    expect(page).to have_button t("navigation.continue")
  end

  def when_i_choose_to_continue
    click_button t("navigation.continue")
  end

  it "should show something went wrong when visiting choose a country page directly with session not supporting eidas" do
    given_a_session_not_supporting_eidas

    visit "/choose-a-country"
    expect(page).to have_content t("errors.something_went_wrong.heading")
  end

  it "should have a heading" do
    given_a_session_supporting_eidas

    visit "/choose-a-country"

    expect(page).to have_current_path(choose_a_country_path)
  end

  it "displays eIDAS schemes" do
    given_a_session_supporting_eidas

    visit "/choose-a-country"

    expect(page).to have_css ".country-picker"
    within("#country-picker") do
      expect(page).to have_content("Stub Country")
      expect(page).to have_button("Select Stub IDP Demo")
    end
  end

  it "should redirect to country page" do
    given_a_session_supporting_eidas
    stub_select_country_request("YY")
    stub_session_country_authn_request(originating_ip, redirect_to_country_path, false)

    visit "/choose-a-country"
    click_button "Select Stub IDP Demo"

    expect(page).to have_current_path("/redirect-to-country")

    then_im_at_the_interstitial_page
    click_button t("navigation.continue")
  end

  it "should redirect to country page when JS is enabled", js: true do
    given_a_session_supporting_eidas
    stub_select_country_request("YY")
    stub_session_country_authn_request(originating_ip, redirect_to_country_path, false)

    visit "/choose-a-country"
    click_button "Select Stub IDP Demo"
  end

  it "should redirect to other-ways-to-access-service" do
    given_a_session_supporting_eidas

    visit "/choose-a-country"
    click_on t("hub.choose_a_country.country_not_listed_link", other_ways_description: "test GOV.UK Verify user journeys")

    expect(page).to have_current_path("/country-not-listed")
  end

  it "includes the appropriate feedback source" do
    given_a_session_supporting_eidas
    visit "/choose-a-country"

    expect_feedback_source_to_be(page, "CHOOSE_A_COUNTRY_PAGE", "/choose-a-country")
  end

  it "displays the page in welsh" do
    given_a_session_supporting_eidas
    visit "/dewiswch-wlad"

    expect(page).to have_title t("hub.choose_a_country.heading", locale: :cy)
    expect(page).to have_css "html[lang=cy]"
  end
end
