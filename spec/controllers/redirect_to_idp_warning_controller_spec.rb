require "rails_helper"
require "controller_helper"
require "api_test_helper"
require "piwik_test_helper"

describe RedirectToIdpWarningController do
  before :each do
    stub_api_select_idp
    stub_api_idp_list_for_registration
    stub_request(:get, INTERNAL_PIWIK.url).with(query: hash_including({}))
    set_session_and_cookies_with_loa("LEVEL_2")
    session[:selected_idp_was_recommended] = [true, false].sample
  end

  context "renders idp logos" do
    subject { get :index, params: { locale: "en" } }

    it "warning page when idp selected" do
      set_selected_idp(
        "simple_id" => "stub-idp-two",
        "entity_id" => "http://idcorp.com",
        "levels_of_assurance" => %w(LEVEL_1 LEVEL_2),
      )

      expect(subject).to render_template(:redirect_to_idp_warning)
    end

    it "error page when no idp selected" do
      session[:selected_provider] = {}

      expect(subject).to render_template("errors/something_went_wrong")
    end

    it "error page when idp not providing registrations" do
      stub_idp = [
        {
            "simpleId" => "stub-idp-one",
            "entityId" => "http://idcorp.com",
            "levelsOfAssurance" => %w(LEVEL_2),
        },
      ]
      stub_api_idp_list_for_registration(stub_idp)
      set_selected_idp(
        "simple_id" => "stub-idp-two",
        "entity_id" => "http://idcorp.com",
        "levels_of_assurance" => %w(LEVEL_1 LEVEL_2),
      )

      expect(subject.status).to equal(400)
      expect(subject).to render_template("errors/something_went_wrong")
    end
  end

  context "continuing to idp" do
    bobs_identity_service = { "simple_id" => "stub-idp-two",
                              "entity_id" => "http://idcorp.com",
                              "levels_of_assurance" => %w(LEVEL_1 LEVEL_2) }
    before :each do
      stub_api_select_idp
      stub_request(:get, INTERNAL_PIWIK.url).with(query: hash_including({}))
    end

    subject { post :continue, params: { locale: "en" } }

    it "redirects to idp website" do
      set_selected_idp bobs_identity_service

      expect(subject).to redirect_to redirect_to_idp_register_path
    end
  end
end
