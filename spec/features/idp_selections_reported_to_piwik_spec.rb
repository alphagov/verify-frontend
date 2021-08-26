require "feature_helper"
require "api_test_helper"
require "piwik_test_helper"

RSpec.describe "When the user selects an IDP" do
  let(:selected_answers) {
    {
      device_type: { device_type_other: true },
      documents: { has_phone_can_app: true, has_valid_passport: true },
    }
  }
  let(:location) { "/test-idp-request-endpoint" }
  let(:idp_1_entity_id) { "http://idcorp.com" }
  let(:idp_2_entity_id) { "other-entity-id" }
  let(:idp_3_entity_id) { "a-different-entity-id" }
  let(:idp_1_simple_id) { "stub-idp-one" }
  let(:idp_2_simple_id) { "stub-idp-two" }
  let(:given_a_session_with_selected_answers) {
    page.set_rack_session(selected_answers: selected_answers)
  }

  let(:idcorp_registration_piwik_request) {
    stub_piwik_idp_registration("IDCorp", selected_answers: selected_answers, recommended: true, segments: %w(pp_app))
  }

  let(:originating_ip) { "<PRINCIPAL IP ADDRESS COULD NOT BE DETERMINED>" }
  let(:encrypted_entity_id) { "an-encrypted-entity-id" }

  before(:each) do
    set_session_and_session_cookies!
    stub_api_select_idp
    stub_api_idp_list_for_sign_in
    stub_api_idp_list_for_registration
    stub_transactions_list
    stub_session_idp_authn_request(originating_ip, location, false)
    given_a_session_with_selected_answers
  end

  it "reports the IDP name to piwik" do
    piwik_registration_virtual_page = idcorp_registration_piwik_request

    visit "/choose-a-certified-company"
    click_button t("hub.choose_a_certified_company.choose_idp", display_name: t("idps.stub-idp-one.name"))
    click_button t("navigation.continue", display_name: t("navigation.continue"))

    expect(piwik_registration_virtual_page).to have_been_made.once
  end

  # TODO: Can't get this test to pass - don't fully understand
  it "appends the IDP name on subsequent selections" do
    idcorp_piwik_request = stub_piwik_idp_registration(
      "IDCorp",
      selected_answers: selected_answers,
      recommended: true,
      segments: %w(pp_app),
    )

    idcorp_and_bobs_piwik_request = stub_piwik_idp_registration(
      "Carol’s Secure ID",
      selected_answers: selected_answers,
      recommended: false,
      idp_list: "IDCorp,Carol’s Secure ID",
      segments: %w(pp_app),
    )

    stub_idp_select_request(idp_2_entity_id, instance_of(String))
    visit "/choose-a-certified-company"
    click_button t("hub.choose_a_certified_company.choose_idp", display_name: t("idps.stub-idp-one.name"))
    click_button t("navigation.continue", display_name: t("idps.stub-idp-one.name"))

    expect(idcorp_piwik_request).to have_been_made.once

    visit "/choose-a-certified-company"
    page.find_by_id("non-recommended-idps-trigger").click
    click_button t("hub.choose_a_certified_company.choose_idp", display_name: t("idps.stub-idp-three.name"))
    click_button t("navigation.continue", display_name: t("idps.stub-idp-three.name"))
    expect(idcorp_and_bobs_piwik_request).to have_been_made.once
  end

  it "truncates IdP names" do
    idps = %w(A B C D E)
    idcorp_piwik_request = stub_piwik_idp_registration(
      "IDCorp",
      recommended: true,
      selected_answers: selected_answers,
      idp_list: idps.join(","),
      segments: %w(pp_app),
    )
    page.set_rack_session(selected_idp_names: idps)
    visit "/choose-a-certified-company"
    click_button t("hub.choose_a_certified_company.choose_idp", display_name: t("idps.stub-idp-one.name"))
    click_button t("navigation.continue", display_name: t("navigation.continue"))

    expect(idcorp_piwik_request).to have_been_made.once
  end
end

def stub_idp_select_request(idp_entity_id, journey_type = nil)
  stub_session_select_idp_request(
    encrypted_entity_id,
    PolicyEndpoints::PARAM_SELECTED_ENTITY_ID => idp_entity_id,
    PolicyEndpoints::PARAM_PRINCIPAL_IP => originating_ip,
    PolicyEndpoints::PARAM_REGISTRATION => true,
    PolicyEndpoints::PARAM_REQUESTED_LOA => LevelOfAssurance::LOA2,
    PolicyEndpoints::PARAM_PERSISTENT_SESSION_ID => instance_of(String), # no longer comes from matomo
    PolicyEndpoints::PARAM_JOURNEY_TYPE => journey_type,
    PolicyEndpoints::PARAM_VARIANT => nil,
  )
end
