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

  # it "should have a correct title" do
  #   stub_session_idp_authn_request(originating_ip, location, false)
  #   visit redirect_to_idp_path
  #   expect(page).to have_title t("hub.redirect_to_idp.heading")
  # end
end

# context "continuing to idp with javascript disabled" do
#   bobs_identity_service = { "simple_id" => "stub-idp-two",
#                             "entity_id" => "http://idcorp.com",
#                             "levels_of_assurance" => %w(LEVEL_1 LEVEL_2) }
#   before :each do
#     stub_session_idp_authn_request("<PRINCIPAL IP ADDRESS COULD NOT BE DETERMINED>", "idp-location", true)
#     stub_request(:get, INTERNAL_PIWIK.url).with(query: hash_including({}))
#   end
#
#   subject { get :register, params: { locale: "en" } }
#
#   it "reports idp registration details to piwik" do
#     bobs_identity_service_idp_name = "Bob’s Identity Service"
#
#     set_selected_idp bobs_identity_service
#     session[:selected_idp_name] = bobs_identity_service_idp_name
#     session[:selected_idp_names] = [bobs_identity_service_idp_name]
#
#     expect(FEDERATION_REPORTER).to receive(:report_idp_registration)
#                                      .with(current_transaction: a_kind_of(Display::RpDisplayData),
#                                            request: a_kind_of(ActionDispatch::Request),
#                                            idp_name: bobs_identity_service_idp_name,
#                                            idp_name_history: [bobs_identity_service_idp_name])
#     subject
#   end
# end

# with JS enabled
