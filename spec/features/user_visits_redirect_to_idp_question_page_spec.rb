require "feature_helper"
require "api_test_helper"
require "piwik_test_helper"

RSpec.describe "When the user visits the redirect to IDP question page" do
  let(:selected_answers) {
    {
      "phone" => { "mobile_phone" => true, "smart_phone" => true },
      "documents" => { "passport" => true },
    }
  }
  let(:originating_ip) { "<PRINCIPAL IP ADDRESS COULD NOT BE DETERMINED>" }
  let(:idp_location) { "/test-idp-request-endpoint" }
  let(:given_an_idp_with_interstitial_question_needed) {
    set_selected_idp_in_session(entity_id: "stub-idp-one-doc-question", simple_id: "stub-idp-one-doc-question")
    page.set_rack_session(
      selected_idp_was_recommended: true,
      selected_answers: selected_answers,
    )
  }

  before(:each) do
    set_session_and_session_cookies!
    given_an_idp_with_interstitial_question_needed
    visit "/redirect-to-idp-question"
  end

  it "displays interstitial question" do
    expect(page.body).to include t("idps.stub-idp-one-doc-question.interstitial_question")
  end

  it "displays document warning text on LOA2" do
    expect(page).to have_content t("hub.redirect_to_idp_question.identity_documents")
  end

  it "does not display document warning text on LOA1" do
    set_loa_in_session("LEVEL_1")
    visit "/redirect-to-idp-question"
    expect(page).to_not have_content t("hub.redirect_to_idp_question.identity_documents")
  end

  it "displays interstitial question in Welsh" do
    visit "/ailgyfeirio-i-gwestiwn-idp"

    expect(page.body).to include t("idps.stub-idp-one-doc-question.interstitial_question", locale: :cy)
    expect(page).to have_css "html[lang=cy]"
  end

  it 'goes to "redirect-to-idp-warning" page if the user answers the question and javascript is enabled', js: true do
    stub_session_idp_authn_request(originating_ip, idp_location, false)

    choose "interstitial_question_form_interstitial_question_result_true", allow_label_click: true

    expected_answers = selected_answers.update("interstitial" => { "interstitial_yes" => true })

    click_button t("navigation.continue")

    expect(page).to have_current_path(redirect_to_idp_warning_path)
    expect(page.get_rack_session["selected_answers"]).to eql(expected_answers)
  end

  it 'goes to "idp-wont-work-for-you" page if the user answers no to the interstitial question and javascript is enabled', js: true do
    choose "interstitial_question_form_interstitial_question_result_false", allow_label_click: true
    click_button t("navigation.continue")
    expect(page).to have_title t("hub.idp_wont_work_for_you_one_doc.title", idp_name: t("idps.stub-idp-one-doc-question.name"))
  end

  it "displays an error message when user does not answer the question when javascript is turned off" do
    click_button t("navigation.continue")

    expect(page).to have_current_path(redirect_to_idp_question_submit_path)
    expect(page).to have_content t("hub.redirect_to_idp_question.validation_message")
  end

  context "when the form is invalid", js: true do
    it "should display validation message if no selection is made" do
      click_button t("navigation.continue")
      expect(page).to have_content t("hub.redirect_to_idp_question.validation_message")
    end

    it "should remove validation message once selection is made" do
      click_button t("navigation.continue")
      expect(page).to have_content t("hub.redirect_to_idp_question.validation_message")
      choose "interstitial_question_form_interstitial_question_result_false", allow_label_click: true
      expect(page).to_not have_content t("hub.redirect_to_idp_question.validation_message")
    end
  end
end
