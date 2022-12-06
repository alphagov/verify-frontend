require "feature_helper"
require "cookie_names"

RSpec.describe "When the user visits the about choosing a company page" do
  before(:each) do
    set_session_and_session_cookies!
  end

  if SIGN_UPS_ENABLED

    context "LOA2" do
      before(:each) do
        stub_api_idp_list_for_registration
      end

      it "will include the appropriate feedback source" do
        visit "/about-choosing-a-company"

        expect_feedback_source_to_be(page, "ABOUT_CHOOSING_A_COMPANY_PAGE", "/about-choosing-a-company")
      end

      it "will display content in Welsh" do
        visit "/am-ddewis-cwmni"

        expect(page).to have_content "Dod o hyd i’r cwmni iawn i’ch dilysu chi"
      end

      it "will take user to will-it-work-for-me page when user clicks 'Continue'" do
        visit "/about-choosing-a-company"

        click_link "Continue"
        expect(page).to have_current_path(will_it_work_for_me_path)
      end
    end

    context "LOA1" do
      before(:each) do
        set_loa_in_session("LEVEL_1")
        stub_api_idp_list_for_registration(loa: "LEVEL_1")
      end

      it "will take user to the IDP picker when they click 'Continue'" do
        visit "/about-choosing-a-company"

        click_link "Continue"
        expect(page).to have_current_path(choose_a_certified_company_path)
      end
    end
  end
end
