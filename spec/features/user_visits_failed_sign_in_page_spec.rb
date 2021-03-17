require "feature_helper"
require "api_test_helper"

RSpec.describe "When the user visits the failed sign in page" do
  before(:each) do
    set_session_and_session_cookies!
  end

  context "#idp" do
    before(:each) do
      stub_api_idp_list_for_registration
      set_selected_idp_in_session(entity_id: "http://idcorp.com", simple_id: "stub-idp-one")
    end

    it "includes expected content" do
      visit "/failed-sign-in"

      expect_feedback_source_to_be(page, "FAILED_SIGN_IN_PAGE", "/failed-sign-in")
      expect(page).to have_title t("hub.failed_sign_in.heading", display_name: "IDCorp")
      expect(page).to have_content t("hub.failed_sign_in.heading", display_name: "IDCorp")
      expect(page.body).to include t("hub.failed_sign_in.reasons_html")
      expect(page).to have_link t("hub.failed_sign_in.start_again"), href: start_path
    end

    it "displays the content in Welsh" do
      visit "/mewngofnodi-wedi-methu"

      expect(page).to have_css "html[lang=cy]"
    end
  end
end
