require "feature_helper"
require "api_test_helper"

RSpec.describe "When the user visits the forgot company page" do
  before(:each) do
    set_session_and_session_cookies!
    stub_api_idp_list_for_registration
  end

  xit "includes the expected content" do
    visit "/forgot-company"

    expect_feedback_source_to_be(page, "FORGOT_COMPANY_PAGE", "/forgot-company")
    expect(page).to have_content "We can’t tell you which company verified you"
    expect(page).to have_link t("navigation.back")
  end

  xit "takes us back to the sign-in page when the Back link is clicked" do
    stub_api_idp_list_for_sign_in
    visit "/forgot-company"
    click_link t("navigation.back")

    expect(page).to have_current_path("/sign-in")
  end

  xit "displays content in Welsh" do
    visit "/wedi-anghofio-cwmni"

    expect(page).to have_content "Ni allwn ddweud wrthych pa gwmni wnaeth eich dilysu"
    expect(page).to have_css "html[lang=cy]"
  end
end
