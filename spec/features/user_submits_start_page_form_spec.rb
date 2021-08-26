require "feature_helper"
require "cookie_names"
require "api_test_helper"
require "piwik_test_helper"
require "sign_in_helper"

RSpec.describe "when user submits start page form" do
  let(:idp_entity_id) { "http://idcorp.com" }
  let(:originating_ip) { "<PRINCIPAL IP ADDRESS COULD NOT BE DETERMINED>" }
  let(:location) { "/test-idp-request-endpoint" }
  let(:idp_display_name) { "IDCorp" }

  def and_the_language_hint_is_set
    expect(page).to have_content("language hint was 'en'")
  end

  def and_the_hints_are_not_set
    expect(page).to have_content("hints are ''")
  end

  before :each do
    set_session_and_session_cookies!
  end

  it "will display about page when user chooses yes (registration)" do
    stub_api_idp_list_for_registration
    stub_request(:get, INTERNAL_PIWIK.url)
    visit "/start"
    choose("start_form_selection_true")
    click_button("next-button")
    expect(current_path).to eq("/about")
  end

  it "will display sign in with IDP page when user chooses sign in" do
    stub_api_idp_list_for_sign_in
    visit "/start"
    choose("start_form_selection_false")
    click_button("next-button")
    expect(current_path).to eq("/sign-in")
    expect(page).to have_content t("hub.signin.heading")
    expect(page).to have_content "IDCorp"
    expect(page).to have_css('.company-logo input[src="/stub-logos/stub-idp-one.png"]')
    expect(page).to have_link t("hub.signin.back"), href: "/start"
    expect_feedback_source_to_be(page, "SIGN_IN_PAGE", "/sign-in")
    expect(page).to have_link t("hub.signin.about_link"), href: "/begin-registration"
    expect(page).to have_link t("hub.signin.forgot_company"), href: "/forgot-company"
  end

  it "will report user choice to analytics when user chooses to sign in" do
    stub_api_idp_list_for_sign_in
    stub_request(:get, INTERNAL_PIWIK.url).with(query: hash_including({}))
    visit "/start"
    choose("start_form_selection_false")
    click_button("next-button")

    piwik_request = {
        "rec" => "1",
        "apiv" => "1",
        "_cvar" => '{"1":["RP","analytics description for test-rp"],"2":["LOA_REQUESTED","LEVEL_2"],"3":["JOURNEY_TYPE","SIGN_IN"]}',
        "action_name" => "The user started a sign-in journey",
    }
    expect(a_request(:get, INTERNAL_PIWIK.url).with(query: hash_including(piwik_request))).to have_been_made.once
  end

  it "will prompt for an answer if no answer is given" do
    stub_api_idp_list_for_registration
    visit "/start"
    click_button("next-button")
    expect(page).to have_content t("hub.start.error_message")
  end

  it "will redirect to the IDP when the user chooses a hinted IDP", js: true do
    stub_session_idp_authn_request(originating_ip, location, false)
    set_journey_hint_cookie(idp_entity_id, "SUCCESS")
    stub_api_idp_list_for_sign_in
    stub_api_select_idp
    visit "/start"
    when_i_select_an_idp idp_display_name
    then_im_at_the_idp journey_type: JourneyType::SIGN_IN_LAST_SUCCESSFUL_IDP
    and_the_language_hint_is_set
    and_the_hints_are_not_set
    expect(page.get_rack_session_key("selected_provider")["identity_provider"]).to include("entity_id" => idp_entity_id, "simple_id" => "stub-idp-one", "levels_of_assurance" => %w(LEVEL_2))
  end

  it "will return the user to the start when ignoring the hint at LOA2", js: true do
    stub_session_idp_authn_request(originating_ip, location, false)
    set_journey_hint_cookie(idp_entity_id, "SUCCESS")
    stub_api_idp_list_for_sign_in
    stub_api_select_idp
    visit "/start"
    expect(page).to have_title t("hub.sign_in_hint.heading")
    expect(page).to have_content t("hub.sign_in_hint.heading")
    visit "/start/ignore-hint"  # the "choose another way" button
    expect(page).to have_title t("hub.start.heading")
    expect(page).to have_content t("hub.start.heading")
  end

  it "will return the user to the start when ignoring the hint at LOA1", js: true do
    stub_session_idp_authn_request(originating_ip, location, false)
    set_journey_hint_cookie(idp_entity_id, "SUCCESS")
    stub_api_idp_list_for_sign_in
    stub_api_select_idp
    visit "/start"
    expect(page).to have_title t("hub.sign_in_hint.heading")
    expect(page).to have_content t("hub.sign_in_hint.heading")
    visit "/start/ignore-hint"  # the "choose another way" button
    expect(page).to have_title t("hub.start.heading")
    expect(page).to have_content t("hub.start.heading")
  end
end
