require "feature_helper"
require "cookie_names"
require "piwik_test_helper"
require "api_test_helper"

RSpec.describe "When the user visits the about page" do
  before(:each) do
    set_session_and_session_cookies!
    stub_api_idp_list_for_registration
  end

  context "session cookie contains transaction id" do
    before(:each) do
      page.set_rack_session(transaction_simple_id: "test-rp")
    end
    it "will display the page and report the user's selection to piwik" do
      visit "/about"

      expect(page).to have_content "GOV.UK Verify is a secure way to prove who you are online. It aims to protect people from the growing problem of online identity theft."
      expect_feedback_source_to_be(page, "ABOUT_PAGE", "/about")

      expect(page).to have_link("Next", href: "/about-certified-companies")
    end

    it "will display the about page in Welsh" do
      visit "/am"
      expect(page).to have_content "Mae GOV.UK Verify yn wasanaeth diogel a adeiladwyd i frwydro"
      expect(page).to have_css "html[lang=cy]"
    end
  end
end
