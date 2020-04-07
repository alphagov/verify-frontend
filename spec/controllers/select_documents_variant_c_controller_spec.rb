require "rails_helper"
require "controller_helper"
require "feature_helper"
require "spec_helper"
require "api_test_helper"
require "piwik_test_helper"
require "models/display/viewable_identity_provider"

describe SelectDocumentsVariantCController do
  before { skip("Short hub AB test temporarily teared down") }

  before(:each) do
    experiment = "short_hub_2019_q3-preview"
    variant = "variant_c_2_idp_short_hub"
    set_session_and_cookies_with_loa_and_variant("LEVEL_2", experiment, variant)
    stub_api_idp_list_for_registration([{ "simpleId" => "stub-idp-one",
                                          "entityId" => "http://idcorp.com",
                                          "levelsOfAssurance" => %w(LEVEL_2) }], "LEVEL_2")
    session[:selected_answers] = {
      "device_type" => { device_type_other: true },
    }
  end

  context "when form is valid" do
    it "redirects to the advice page when less than three documents are selected" do
      evidence = { has_valid_passport: "t", has_credit_card: "t" }.freeze
      post :select_documents, params: { locale: "en", select_documents_variant_c_form: evidence }
      expect(subject).to redirect_to select_documents_advice_path
    end

    it "redirects to the company picker when at least three documents are available" do
      evidence = { has_valid_passport: "t", has_credit_card: "t", has_phone_can_app: "t" }.freeze
      post :select_documents, params: { locale: "en", select_documents_variant_c_form: evidence }

      expect(subject).to redirect_to choose_a_certified_company_path
    end
  end

  context "when form is invalid" do
    subject { post :select_documents, params: { locale: "en" } }

    it "renders itself" do
      expect(subject).to render_template(:index)
    end

    it "does not report to Piwik" do
      expect(ANALYTICS_REPORTER).not_to receive(:report_action)
    end
  end
end
