require "feature_helper"
require "api_test_helper"

RSpec.describe "When the user visits the redirect to IDP page" do
  let(:originating_ip) { "<PRINCIPAL IP ADDRESS COULD NOT BE DETERMINED>" }
  let(:location) { "/test-idp-request-endpoint" }
  let(:selected_answers) { { phone: { mobile_phone: true, smart_phone: false }, documents: { passport: true } } }
  let(:idp_entity_id) { "http://idcorp.com" }
  let(:given_a_session_with_a_hints_enabled_idp) {
    set_selected_idp_in_session(entity_id: idp_entity_id, simple_id: "stub-idp-one")
    page.set_rack_session(
      selected_idp_name: "Demo IDP",
      selected_idp_names: ["IDP 1", "IDP 2"],
      selected_idp_was_recommended: true,
      selected_answers: selected_answers,
    )
  }
  let(:given_a_session_with_a_hints_disabled_idp) {
    set_selected_idp_in_session(entity_id: idp_entity_id, simple_id: "stub-idp-two")
    page.set_rack_session(
      selected_idp_name: "Demo IDP",
      selected_idp_names: ["IDP 1", "IDP 2"],
      selected_idp_was_recommended: true,
      selected_answers: selected_answers,
    )
  }

  before(:each) do
    set_session_and_session_cookies!
  end

  it "should contain hint inputs if hints are enabled for the IDP" do
    given_a_session_with_a_hints_enabled_idp
    stub_session_idp_authn_request(originating_ip, location, true)
    visit redirect_to_idp_register_path
    expect(page).to have_css('input[name="hint"][value="has_ukpassport"]', visible: false)
    expect(page).to have_css('input[name="hint"][value="has_mobile"]', visible: false)
    expect(page).to have_css('input[name="hint"][value="not_apps"]', visible: false)
    expect(page).to have_css('input[name="language"][value="en"]', visible: false)
    expect(page).to_not have_css('input[name="hint"][value="has_nonukid"]', visible: false)
  end

  it "should contain welsh language hint" do
    given_a_session_with_a_hints_enabled_idp
    stub_session_idp_authn_request(originating_ip, location, true)
    visit "/#{t('routes.redirect_to_idp_register', locale: 'cy')}"
    expect(page).to have_css('input[name="language"][value="cy"]', visible: false)
  end

  it "should not contain hint inputs if hints are disabled for the IDP" do
    given_a_session_with_a_hints_disabled_idp
    stub_session_idp_authn_request(originating_ip, location, true)
    visit redirect_to_idp_register_path
    expect(page).to_not have_css('input[name="hint"]', visible: false)
    expect(page).to_not have_css('input[name="language"]', visible: false)
  end

  it "should not contain hint input if user is signing in" do
    given_a_session_with_a_hints_enabled_idp
    stub_session_idp_authn_request(originating_ip, location, false)
    visit redirect_to_idp_sign_in_path
    expect(page).to_not have_css('input[name="hint"]', visible: false)
  end

  it "should have a correct title" do
    given_a_session_with_a_hints_enabled_idp
    stub_session_idp_authn_request(originating_ip, location, false)
    visit redirect_to_idp_register_path
    expect(page).to have_title t("hub.redirect_to_idp.heading")
  end
end
