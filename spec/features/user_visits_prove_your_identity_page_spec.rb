require "feature_helper"
require "api_test_helper"

RSpec.describe "When the user visits the prove identity page" do
  before(:each) do
    stub_request(:get, "http://api.com:50240/config/transactions/enabled").to_return(
      status: 200,
      body: '[{"simpleId":"test-rp","serviceHomepage":"http://localhost:50130/test-rp","loaList":["LEVEL_2"]}]',
      headers: {},
    )
  end

  context "will display the prove identity page" do
    before(:each) do
      set_session_and_session_cookies!
    end

    it "in English" do
      visit "/prove-identity"
      expect(page).to have_content t("hub.prove_identity.heading")
      expect(page).to have_css "html[lang=en]"
      expect_feedback_source_to_be(page, "PROVE_IDENTITY_PAGE", "/prove-identity")
    end

    it "will display the hint page if an success hint present" do
      set_journey_hint_cookie("http://idcorp.com", "SUCCESS")
      stub_api_idp_list_for_sign_in
      visit "/prove-identity"
      expect(page).to have_content t("hub.sign_in_hint.heading")
      expect(page).to have_css "html[lang=en]"
    end

    it "will reset the hint and display prove-identity page when user ignores the hint" do
      set_journey_hint_cookie("http://idcorp.com", "SUCCESS")
      stub_api_idp_list_for_sign_in
      visit "/prove-identity"
      expect(page).to have_content t("hub.sign_in_hint.heading")
      expect(page).to have_css "html[lang=en]"
      expect(page).to have_current_path "/prove-identity"

      click_link t("hub.sign_in_hint.other_way_button")

      expect(page).to have_content t("hub.prove_identity.heading")
      expect(page).to have_css "html[lang=en]"
      expect(page).to have_current_path "/prove-identity"
    end

    it "in Welsh" do
      visit "/profi-hunaniaeth"
      expect(page).to have_content t("hub.prove_identity.heading", locale: :cy)
      expect(page).to have_css "html[lang=cy]"
    end

    context "when selecting Verify option" do
      it "should redirect to start page" do
        visit "/prove-identity"
        click_on t("hub.prove_identity.use_verify.button_text")

        expect(page).to have_current_path(start_path)
        expect(page.get_rack_session.key?("selected_provider")).to be_falsey
      end

      it "should redirect to start page and not restart journey if IDP is selected" do
        set_selected_idp_in_session("stub-idp")

        visit "/prove-identity"
        click_on t("hub.prove_identity.use_verify.button_text")

        expect(page).to have_current_path(start_path)
        expect(page.get_rack_session_key("selected_provider")["identity_provider"]).to eq("stub-idp")
      end
    end
  end

  it "will display the no cookies error when all cookies are missing" do
    allow(Rails.logger).to receive(:info)
    expect(Rails.logger).to receive(:info).with("No session cookies can be found").at_least(:once)
    visit "/prove-identity"
    expect(page).to have_content t("errors.no_cookies.enable_cookies")
    expect(page).to have_http_status :forbidden
    expect(page).to have_link "feedback", href: "/feedback-landing?feedback-source=COOKIE_NOT_FOUND_PAGE"
    t("hub.transaction_list.items").each do |transaction|
      expect(page).to have_link transaction[:name], href: transaction[:homepage]
    end
  end
end
