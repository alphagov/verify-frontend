require "rails_helper"
require "controller_helper"
require "api_test_helper"
require "piwik_test_helper"

describe ChooseACertifiedCompanyLoa1Controller do
  let(:stub_idp_loa1) {
    {
        "simpleId" => "stub-idp-loa1",
        "entityId" => "http://idcorp-loa1.com",
        "levelsOfAssurance" => %w(LEVEL_1 LEVEL_2),
    }.freeze
  }

  let(:stub_idp_loa1_with_interstitial) {
    {
        "simpleId" => "stub-idp-loa1-with-interstitial",
        "entityId" => "http://idcorp-loa1-with-interstitial.com",
        "levelsOfAssurance" => %w(LEVEL_1 LEVEL_2),
    }.freeze
  }

  let(:stub_idp_no_interstitial) {
    {
        "simpleId" => "stub-idp-two",
        "entityId" => "http://idcorp-two.com",
        "levelsOfAssurance" => %w(LEVEL_1"),
    }.freeze
  }

  context "#index" do
    before :each do
      stub_api_idp_list_for_registration([stub_idp_loa1, stub_idp_loa1_with_interstitial], "LEVEL_1")
    end

    it "renders IDP list" do
      set_session_and_cookies_with_loa("LEVEL_1", "test-rp")
      stub_piwik_request = stub_piwik_report_number_of_recommended_idps(2, "LEVEL_1", "analytics description for test-rp")

      expect(IDENTITY_PROVIDER_DISPLAY_DECORATOR).to receive(:decorate_collection).once do |idps|
        idps.each { |idp| expect(idp.levels_of_assurance).to include "LEVEL_1" }
      end

      get :index, params: { locale: "en" }

      expect(subject).to render_template(:choose_a_certified_company_LOA1)
      expect(stub_piwik_request).to have_been_made.once
    end
  end

  context "#select_idp" do
    before :each do
      set_session_and_cookies_with_loa("LEVEL_1")
      stub_api_idp_list_for_registration([stub_idp_loa1, stub_idp_loa1_with_interstitial], "LEVEL_1")
    end

    it "resets interstitial answer to no value when IDP is selected" do
      session[:selected_answers] = { "interstitial" => { "interstitial_yes" => true } }
      post :select_idp, params: { locale: "en", entity_id: "http://idcorp.com" }

      expect(session[:selected_answers]["interstitial"]).to be_empty
    end

    it "sets selected IDP in user session" do
      post :select_idp, params: { locale: "en", entity_id: "http://idcorp-loa1.com" }

      expect(session[:selected_provider].entity_id).to eql("http://idcorp-loa1.com")
    end

    it "checks whether IDP was recommended" do
      post :select_idp, params: { locale: "en", entity_id: "http://idcorp-loa1.com" }

      expect(session[:selected_idp_was_recommended]).to eql(true)
    end

    it "redirects to IDP warning page by default" do
      stub_api_idp_list_for_registration([stub_idp_no_interstitial], "LEVEL_1")
      post :select_idp, params: { locale: "en", entity_id: "http://idcorp-two.com" }

      expect(subject).to redirect_to redirect_to_idp_warning_path
    end

    it "redirects to IDP question page for LOA1 users when IDP flag is enabled" do
      post :select_idp, params: { locale: "en", entity_id: "http://idcorp-loa1-with-interstitial.com" }

      expect(subject).to redirect_to redirect_to_idp_question_path
    end

    it "returns 404 page if IDP is non-existent" do
      post :select_idp, params: { locale: "en", entity_id: "http://notanidp.com" }

      expect(response).to have_http_status :not_found
    end

    it "returns 400 if `entity_id` param is not present" do
      post :select_idp, params: { locale: "en" }

      expect(subject).to render_template "errors/something_went_wrong"
      expect(response).to have_http_status :bad_request
    end
  end

  context "#about" do
    it "returns 404 page if no display data exists for IDP" do
      set_session_and_cookies_with_loa("LEVEL_1")
      stub_api_idp_list_for_registration([stub_idp_loa1], "LEVEL_1")

      get :about, params: { locale: "en", company: "unknown-idp" }

      expect(subject).to render_template "errors/404"
      expect(response).to have_http_status :not_found
    end
  end
end
