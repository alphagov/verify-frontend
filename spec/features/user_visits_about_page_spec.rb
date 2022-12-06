require "feature_helper"
require "cookie_names"
require "piwik_test_helper"
require "api_test_helper"

RSpec.describe "When the user visits the about page" do
  before(:each) do
    stub_api_idp_list_for_registration
    page.set_rack_session(transaction_simple_id: "test-rp")
    set_session_and_session_cookies!
  end
  if SIGN_UPS_ENABLED
    it "will display the combined about page" do
      visit "/about"
      expect(page).to have_content "GOV.UK Verify is a secure way to prove who you are online. It helps protect you against online identity theft."
      expect(page).to have_content "You create an identity account with a company that meets government privacy and security standards."
      expect(page).to have_content "The company will ask you questions and check your identity documents."
      expect(page).to have_content "It will never share your information for any other purpose without your consent."

      expect_feedback_source_to_be(page, "ABOUT_VERIFY_PAGE", "/about")

      expect(page).to have_link(t("navigation.continue"))
    end

    it "will display the about page in Welsh." do
      visit "/am"

      expect(page).to have_content("Neidio i'r prif gynnwys")
      expect(page).to have_content "Gallwch greu cyfrif hunaniaeth gyda chwmni sydd yn cwrdd â safonau preifatrwydd a diogelwch y llywodraeth."
      expect(page).to have_link("Parhau", href: "/a-fydd-yn-gweithio-i-mi")
      expect(page).to have_css "html[lang=cy]"
    end
  end
end
