require "feature_helper"
require "cookie_names"

RSpec.describe "When the user visits the about choosing a company page" do
  before(:each) do
    set_session_and_session_cookies!
    stub_api_idp_list_for_registration
  end

  it "will include the appropriate feedback source" do
    visit "/about-documents"

    expect_feedback_source_to_be(page, "ABOUT_DOCUMENTS_PAGE", "/about-documents")
  end

  it "will display content in Welsh" do
    visit "/am-ddogfennau"

    expect(page).to have_content t("hub.about.documents.heading", locale: :cy)
  end

  it "will take the user to the IDP picker page when they click 'Continue'" do
    visit "/about-documents"

    click_link "Continue"
    expect(page).to have_current_path(choose_a_certified_company_path)
  end

  it "will take the user to the prove your identity another way page when they click the link" do
    visit "/about-documents"

    click_link t("hub.about.documents.prove_identity_another_way.link_text")
    expect(page).to have_current_path(prove_your_identity_another_way_path)
  end
end
