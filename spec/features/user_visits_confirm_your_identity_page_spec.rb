require "feature_helper"
require "api_test_helper"

def stub_api_and_analytics(idp_location = ApiTestHelper::IDP_LOCATION)
  stub_session_select_idp_request("an-encrypted-entity-id")
  stub_session_idp_authn_request(ApiTestHelper::ORIGINATING_IP, idp_location)
  stub_request(:get, INTERNAL_PIWIK.url).with(query: hash_including({}))
end

def set_up_session(idp_entity_id)
  stub_api_and_analytics
  stub_api_idp_list_for_sign_in
  set_session_and_session_cookies!
  set_journey_hint_cookie(idp_entity_id)
  page.set_rack_session(
    transaction_simple_id: "test-rp",
    selected_idp_name: "Demo IDP",
    selected_idp_names: [],
    requested_loa: "LEVEL_1",
    )
end

RSpec.describe "When the user visits the confirm-your-identity page" do
  describe "and the journey hint cookie is set" do
    before(:each) do
      set_up_session("http://idcorp.com")
    end

    it "displays the page in Welsh" do
      visit "/cadarnhau-eich-hunaniaeth"
      expect(page).to have_title t("hub.signin.sign_in_idp", display_name: "Welsh IDCorp", locale: :cy)
      expect(page).to have_css "html[lang=cy]"
    end

    it "displays the page in English" do
      visit confirm_your_identity_path
      expect(page).to have_title t("hub.signin.sign_in_idp", display_name: "IDCorp")
      expect(page).to have_css "html[lang=en]"
    end

    it "includes the appropriate feedback source" do
      visit confirm_your_identity_path
      expect_feedback_source_to_be(page, "CONFIRM_YOUR_IDENTITY", confirm_your_identity_path)
    end

    it "includes rp display name in text" do
      visit confirm_your_identity_path
      expect(page).to have_text t("hub.confirm_your_identity.need_to_signin_again", transaction_name: "test GOV.UK Verify user journeys")
    end

    it "should include a link to sign-in in case listed idp is incorrect" do
      stub_api_idp_list_for_sign_in
      visit confirm_your_identity_path
      expect(page).to have_link t("hub.confirm_your_identity.sign_in_link_message"), href: "/sign-in"
    end

    it "should display only the idp that the user last verified with" do
      visit confirm_your_identity_path
      expect(page).to have_button "Sign in with IDCorp"
      expect(page).to have_css(".company", count: 1)
    end

    describe "and js is disabled" do
      it "should display the interstitial page" do
        stub_api_idp_list_for_sign_in
        visit confirm_your_identity_path

        click_button "Sign in with IDCorp"
        expect(page).to have_current_path(sign_in_path)
        expect(page).to have_title t("hub.redirect_to_idp.heading")

        click_button t("navigation.continue")
        expect(page).to have_current_path(ApiTestHelper::IDP_LOCATION)
      end
    end

    describe "and js is enabled", js: true do
      it "should redirect to the IDP sign in page" do
        stub_api_idp_list_for_sign_in
        visit confirm_your_identity_path
        click_button "Sign in with IDCorp"
        expect(page).to have_current_path(ApiTestHelper::IDP_LOCATION)
      end
    end

    describe "and the user wants to select a new IDP" do
      it "should update the cookie" do
        stub_api_idp_list_for_sign_in
        # User has previously chosen IDCorp
        visit confirm_your_identity_path
        expect(page).to have_button("Sign in with IDCorp")

        # User returns to sign in page and selects a new IDP
        click_link "sign in with a different certified company"
        new_idp_location = "/another-idp-endpoint"
        stub_api_and_analytics(new_idp_location)

        click_button "Select Bob’s Identity Service"
        expect(page).to have_title t("hub.redirect_to_idp.heading")

        click_button t("navigation.continue")
        expect(page).to have_current_path(new_idp_location)

        # The new IDP is displayed for non-repudiation
        visit confirm_your_identity_path

        click_button "Sign in with Bob’s Identity Service"
        expect(page).to have_title t("hub.redirect_to_idp.heading")

        click_button t("navigation.continue")
        expect(page).to have_current_path(new_idp_location)
      end
    end
  end

  describe "and the journey hint cookie is invalid in some way" do
    it "should redirect to sign in page when the journey cookie is not set" do
      set_session_and_session_cookies!
      stub_api_idp_list_for_sign_in
      visit confirm_your_identity_path
      expect(page).to have_title t("hub.signin.heading")
      expect(page).to have_current_path(sign_in_path)
    end

    it "should redirect to sign in page when the journey cookie has a nil value" do
      set_session_and_session_cookies!
      stub_api_idp_list_for_sign_in
      visit confirm_your_identity_path
      expect(page).to have_title t("hub.signin.heading")
      expect(page).to have_current_path(sign_in_path)
    end

    it "should redirect to sign in page when the journey cookie has an invalid entity ID" do
      set_up_session("bad-entity-id")
      stub_api_idp_list_for_sign_in
      visit confirm_your_identity_path
      expect(page).to have_title t("hub.signin.heading")
      expect(page).to have_current_path(sign_in_path)
    end
  end

  describe "when the user changes language" do
    it "will preserve the language from sign-in" do
      set_up_session("stub-idp-one")
      stub_api_idp_list_for_sign_in
      stub_session_creation
      visit "/sign-in"
      first(".available-languages").click_link("Cymraeg")
      expect(page).to have_current_path("/mewngofnodi")
      click_button "Ddewis Welsh IDCorp"

      visit "/test-saml"
      click_button "saml-post-journey-hint-non-repudiation"
      expect(page).to have_title t("hub.signin.sign_in_idp", display_name: "Welsh IDCorp", locale: :cy)
      expect(page).to have_current_path("/cadarnhau-eich-hunaniaeth")
      expect(page).to have_css "html[lang=cy]"
    end
  end
end
