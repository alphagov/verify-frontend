require "feature_helper"
require "api_test_helper"

RSpec.feature "when user visits prove your identity another way page", type: :feature do
  let(:service_name) { "test GOV.UK Verify user journeys" }
  before(:each) do
    set_session_and_session_cookies!
    stub_api_idp_list_for_registration
  end

  it "includes the appropriate feedback source" do
    visit prove_your_identity_another_way_path

    expect_feedback_source_to_be(page, "PROVE_YOUR_IDENTITY_ANOTHER_WAY_PAGE", "/prove-your-identity-another-way")
  end

  it "shows prove your identity another way header and you can still service name sub header" do
    visit prove_your_identity_another_way_path

    expect(page).to have_content t("hub_variant_c.prove_your_identity_another_way.heading")
    expect(page).to have_content t("hub_variant_c.prove_your_identity_another_way.sub_heading", service_name: service_name)
  end
end
