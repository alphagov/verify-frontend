require "feature_helper"
require "cookie_names"

RSpec.describe "When the user visits the about choosing a company page" do
  if SIGN_UPS_ENABLED
    context "when there is more than one idp" do
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

        expect(page).to have_content t("hub.about.documents.multi_idp.heading", locale: :cy)
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
    context "when there is just one idp" do
      before(:each) do
        set_session_and_session_cookies!
        stub_api_idp_list_for_registration([{ "simpleId" => "stub-idp-loa1", "entityId" => "http://idcorp-loa1.com", "levelsOfAssurance" => %w(LEVEL_1 LEVEL_2), "enabled" => true }])
      end

      it "It will give you the single idp view" do
        visit "/about-documents"

        expect(page).to have_content t("hub.about.documents.one_idp.heading", idp: "LOA1 Corp")
      end

      it "will take the user to the prove your identity another way page when they click the link" do
        visit "/about-documents"

        click_link t("hub.about.documents.prove_identity_another_way.link_text")
        expect(page).to have_current_path(prove_your_identity_another_way_path)
      end
    end
  end
end
