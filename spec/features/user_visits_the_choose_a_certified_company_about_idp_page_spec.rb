require "feature_helper"
require "api_test_helper"

RSpec.feature "user visits the choose a certified company about idp page", type: :feature do
  before(:each) do
    set_session_and_session_cookies!
    stub_api_idp_list_for_registration
  end

  let(:idp_location) { "/test-idp-request-endpoint" }
  let(:originating_ip) { "<PRINCIPAL IP ADDRESS COULD NOT BE DETERMINED>" }
  let(:given_a_session_with_selected_idp) {
    set_selected_idp_in_session(entity_id: "http://idcorp.com", simple_id: "stub-idp-one")
  }

  scenario "user chooses a recommended idp" do
    entity_id = "my-entity-id"
    given_a_session_with_selected_idp
    stub_session_idp_authn_request
    select_idp_stub_request(entity_id)
    stub_api_idp_list_for_sign_in [{ "simpleId" => "stub-idp-one", "entityId" => entity_id, "levelsOfAssurance" => %w(LEVEL_1 LEVEL_2) }]
    stub_api_idp_list_for_registration([{ "simpleId" => "stub-idp-one", "entityId" => entity_id, "levelsOfAssurance" => %w(LEVEL_1 LEVEL_2) }])

    visit choose_a_certified_company_about_path("stub-idp-one")
    expect(page).to have_title t("hub.choose_a_certified_company.about.heading", display_name: t("idps.stub-idp-one.name"))
    expect(page).to have_content("ID Corp is the premier identity proofing service around.")

    click_button t("hub.choose_a_certified_company.choose_idp", display_name: t("idps.stub-idp-one.name"))
    expect(page).to have_current_path(redirect_to_idp_register_path)
    expect(page.get_rack_session_key("selected_provider")["identity_provider"]).to include("entity_id" => entity_id, "simple_id" => "stub-idp-one", "levels_of_assurance" => %w(LEVEL_1 LEVEL_2))
  end

  scenario "for a non-existent idp" do
    visit choose_a_certified_company_about_path("foobar")
    expect(page).to have_content t("errors.page_not_found.heading")
  end

  scenario "for an idp that is not viewable" do
    visit choose_a_certified_company_about_path("foobar")
    expect(page).to have_content t("errors.page_not_found.heading")
  end

  scenario "user clicks back link" do
    entity_id = "my-entity-id"
    given_a_session_with_selected_idp
    stub_api_idp_list_for_registration([{ "simpleId" => "stub-idp-one", "entityId" => entity_id, "levelsOfAssurance" => %w(LEVEL_1 LEVEL_2) }])

    visit choose_a_certified_company_about_path("stub-idp-one")
    click_link t("navigation.back")

    expect(page).to have_current_path(choose_a_certified_company_path)
  end

  def select_idp_stub_request(entity_id)
    stub_session_select_idp_request(
      entity_id,
      PolicyEndpoints::PARAM_SELECTED_ENTITY_ID => entity_id,
      PolicyEndpoints::PARAM_PRINCIPAL_IP => originating_ip,
      PolicyEndpoints::PARAM_REGISTRATION => true,
      PolicyEndpoints::PARAM_REQUESTED_LOA => "LEVEL_2",
      PolicyEndpoints::PARAM_PERSISTENT_SESSION_ID => instance_of(String), # no longer comes from matomo
      PolicyEndpoints::PARAM_JOURNEY_TYPE => nil,
      PolicyEndpoints::PARAM_VARIANT => nil,
    )
  end
end
