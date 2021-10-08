require "feature_helper"
require "api_test_helper"

RSpec.describe "When the user visits the redirect to IDP page" do
  let(:originating_ip) { "<PRINCIPAL IP ADDRESS COULD NOT BE DETERMINED>" }
  let(:location) { "/test-idp-request-endpoint" }
  let(:idp_entity_id) { "http://idcorp.com" }

  before(:each) do
    set_session_and_session_cookies!
    set_selected_idp_in_session(entity_id: idp_entity_id, simple_id: "stub-idp-one")
    page.set_rack_session(
      selected_idp_name: "Demo IDP",
      selected_idp_names: ["IDP 1", "IDP 2"],
    )
  end

  it "should have a correct title" do
    stub_session_idp_authn_request(originating_ip, location, false)
    visit redirect_to_idp_register_path
    expect(page).to have_title t("hub.redirect_to_idp.heading")
  end
end
