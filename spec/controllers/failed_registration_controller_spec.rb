require "rails_helper"
require "controller_helper"
require "spec_helper"
require "api_test_helper"

describe FailedRegistrationController do
  WITH_DEFAULT_FAILED_REGISTRATION_MESSAGE_RP = "test-rp".freeze
  WITH_CUSTOM_FAILED_REGISTRATION_MESSAGE_RP = "test-rp-no-demo".freeze

  before(:each) do
    set_selected_idp(entity_id: "http://idcorp.com", simple_id: "stub-idp-one", levels_of_assurance: [LevelOfAssurance::LOA1, LevelOfAssurance::LOA2])
  end

  subject { get :index, params: { locale: "en" } }

  context "renders LOA1" do
    before :each do
      set_session_and_cookies_with_loa(LevelOfAssurance::LOA1)
      session[:selected_idp_was_recommended] = false
    end

    it "displays the default failed registration message" do
      stub_api_idp_list_for_registration(default_idps, LevelOfAssurance::LOA1)
      set_transaction(WITH_DEFAULT_FAILED_REGISTRATION_MESSAGE_RP)
      expect(subject).to render_template(:failed_registration)
    end
  end

  context "renders LOA2" do
    before :each do
      set_session_and_cookies_with_loa(LevelOfAssurance::LOA2)
      session[:selected_idp_was_recommended] = false
    end

    it "displays the default failed registration message" do
      stub_api_idp_list_for_registration(default_idps)
      set_transaction(WITH_DEFAULT_FAILED_REGISTRATION_MESSAGE_RP)

      expect(subject).to render_template(:failed_registration)
    end

    it "displays the RP's custom failed registration message" do
      set_transaction(WITH_CUSTOM_FAILED_REGISTRATION_MESSAGE_RP)

      expect(subject).to render_template(:custom_failed_registration)
    end
  end
end
