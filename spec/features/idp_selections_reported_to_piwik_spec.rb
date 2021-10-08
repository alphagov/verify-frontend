require "feature_helper"
require "api_test_helper"
require "piwik_test_helper"

RSpec.describe "When the user selects an IDP" do
  let(:idp_1_entity_id) { "http://idcorp.com" }
  let(:idp_2_entity_id) { "other-entity-id" }
  let(:idp_3_entity_id) { "a-different-entity-id" }
  let(:idp_1_simple_id) { "stub-idp-one" }
  let(:idp_2_simple_id) { "stub-idp-two" }

  let(:idcorp_registration_piwik_request) {
    stub_piwik_idp_registration("IDCorp")
  }

  before(:each) do
    set_session_and_session_cookies!
    set_journey_type_in_session(JourneyType::REGISTRATION)
    stub_api_select_idp
    stub_api_idp_list_for_sign_in
    stub_api_idp_list_for_registration
    stub_transactions_list
    stub_session_idp_authn_request
  end

  it "reports the IDP name to piwik" do
    piwik_registration_virtual_page = idcorp_registration_piwik_request

    visit "/choose-a-certified-company"
    click_button t("hub.choose_a_certified_company.choose_idp", display_name: t("idps.stub-idp-one.name"))
    click_button t("navigation.continue", display_name: t("navigation.continue"))

    expect(piwik_registration_virtual_page).to have_been_made.once
  end

  it "appends the IDP name on subsequent selections" do
    idcorp_piwik_request = stub_piwik_idp_registration(t("idps.stub-idp-one.name"))

    idcorp_and_bobs_piwik_request = stub_piwik_idp_registration(
      t("idps.stub-idp-two.name"), idp_list: "#{t('idps.stub-idp-one.name')},#{t('idps.stub-idp-two.name')}"
    )

    stub_idp_select_request(idp_2_entity_id, instance_of(String))
    visit "/choose-a-certified-company"
    click_button t("hub.choose_a_certified_company.choose_idp", display_name: t("idps.stub-idp-one.name"))
    click_button t("navigation.continue", display_name: t("idps.stub-idp-one.name"))

    expect(idcorp_piwik_request).to have_been_made.once

    visit "/choose-a-certified-company"
    click_button t("hub.choose_a_certified_company.choose_idp", display_name: t("idps.stub-idp-two.name"))
    click_button t("navigation.continue", display_name: t("idps.stub-idp-two.name"))
    expect(idcorp_and_bobs_piwik_request).to have_been_made.once
  end

  it "truncates IdP names" do
    idps = %w(A B C D E)
    idps_reported = %w(B C D E IDCorp)
    idcorp_piwik_request = stub_piwik_idp_registration("IDCorp", idp_list: idps_reported.join(","))

    page.set_rack_session(selected_idp_names: idps)
    visit "/choose-a-certified-company"
    click_button t("hub.choose_a_certified_company.choose_idp", display_name: t("idps.stub-idp-one.name"))
    click_button t("navigation.continue", display_name: t("navigation.continue"))

    expect(idcorp_piwik_request).to have_been_made.once
  end
end

def stub_idp_select_request(idp_entity_id, journey_type = nil)
  stub_session_select_idp_request(
    "an-encrypted-entity-id",
    PolicyEndpoints::PARAM_SELECTED_ENTITY_ID => idp_entity_id,
    PolicyEndpoints::PARAM_PRINCIPAL_IP => ApiTestHelper::ORIGINATING_IP,
    PolicyEndpoints::PARAM_REGISTRATION => true,
    PolicyEndpoints::PARAM_REQUESTED_LOA => "LEVEL_2",
    PolicyEndpoints::PARAM_PERSISTENT_SESSION_ID => instance_of(String), # no longer comes from matomo
    PolicyEndpoints::PARAM_JOURNEY_TYPE => journey_type,
    PolicyEndpoints::PARAM_VARIANT => nil,
  )
end
