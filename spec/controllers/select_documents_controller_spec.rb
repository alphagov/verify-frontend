require "rails_helper"
require "controller_helper"
require "feature_helper"
require "spec_helper"
require "api_test_helper"
require "piwik_test_helper"
require "models/display/viewable_identity_provider"

describe SelectDocumentsController do
  before(:each) do
    set_session_and_cookies_with_loa("LEVEL_2")
    stub_api_idp_list_for_registration
    session[:selected_answers] = {
      "device_type" => { device_type_other: true },
    }
  end

  context "when form is valid" do
    it "redirects to the advice page when less than three documents are selected" do
      evidence = { has_valid_passport: "t", has_credit_card: "t", has_nothing: "t" }.freeze
      expect_federation_reporter_to_receive_user_evidence_when_posted(evidence)
      expect(subject).to redirect_to select_documents_advice_path
    end

    it "redirects to the advice page when None of the above is selected" do
      evidence = { has_nothing: "t" }
      expect_federation_reporter_to_receive_user_evidence_when_posted(evidence)
      expect(subject).to redirect_to select_documents_advice_path
    end

    it "redirects to the company picker when at least three documents are available" do
      evidence = { has_driving_license: "t", has_credit_card: "t", has_phone_can_app: "t" }.freeze
      post :select_documents, params: { locale: "en", select_documents_form: evidence }

      expect(subject).to redirect_to choose_a_certified_company_path
    end

    it "redirects to the company picker when passport and phone are available" do
      evidence = { has_valid_passport: "t", has_phone_can_app: "t" }.freeze
      post :select_documents, params: { locale: "en", select_documents_form: evidence }

      expect(subject).to redirect_to choose_a_certified_company_path
    end
  end

  context "when form is invalid" do
    subject { post :select_documents, params: { locale: "en" } }

    it "renders itself" do
      expect(subject).to render_template(:index)
    end

    it "does not report to Piwik" do
      expect(FEDERATION_REPORTER).not_to receive(:report_action)
    end
  end

  def expect_federation_reporter_to_receive_user_evidence_when_posted(evidence)
    expect(FEDERATION_REPORTER).to receive(:report_user_evidence_attempt)
    .with(
      current_transaction: a_kind_of(Display::RpDisplayData),
      request: a_kind_of(ActionDispatch::Request),
      attempt_number: 1,
      evidence_list: { device_type_other: true }.merge!(evidence).keys - %i(has_nothing),
    )
    post :select_documents, params: { locale: "en", select_documents_form: evidence }
  end
end
