require "feature_helper"
require "api_test_helper"

RSpec.feature "when user visits prove your identity another way page", type: :feature do
  let(:service_name) { "test GOV.UK Verify user journeys" }
  before(:each) do
    experiment = { "short_hub_2019_q3-preview" => "short_hub_2019_q3-preview_variant_c_2_idp_short_hub" }
    set_session_and_ab_session_cookies!(experiment)
    stub_api_idp_list_for_registration
  end

  it "includes the appropriate feedback source" do
    visit prove_your_identity_another_way_path

    expect_feedback_source_to_be(page, "PROVE_YOUR_IDENTITY_ANOTHER_WAY_PAGE", "/prove-your-identity-another-way")
  end

  it "shows prove your identity another way header and you can still service name sub header" do
    visit prove_your_identity_another_way_path

    expect(page).to have_content t("hub_variant_c.select_documents_advice.what_to_do_next.prove_your_identity_link").capitalize
    expect(page).to have_content service_name
  end
end
