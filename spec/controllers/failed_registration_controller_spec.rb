require "rails_helper"
require "controller_helper"
require "spec_helper"
require "api_test_helper"

describe FailedRegistrationController do
  WITH_CONTINUE_ON_FAILED_REGISTRATION_RP = "test-rp-with-continue-on-fail".freeze
  WITH_NON_CONTINUE_ON_FAILED_REGISTRATION_RP = "test-rp".freeze
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

    it "non continue on failed registration view when rp is not allowed to continue on failed" do
      stub_api_idp_list_for_registration(default_idps, LevelOfAssurance::LOA1)
      set_transaction(WITH_NON_CONTINUE_ON_FAILED_REGISTRATION_RP)
      expect(subject).to render_template(:non_continue_on_failed_registration_rp)
    end

    it "continue on failed registration view when rp is allowed to continue on failed" do
      set_transaction(WITH_CONTINUE_ON_FAILED_REGISTRATION_RP)

      expect(subject).to render_template(:continue_on_failed_registration_rp)
    end
  end

  context "renders LOA2" do
    before :each do
      set_session_and_cookies_with_loa(LevelOfAssurance::LOA2)
      session[:selected_idp_was_recommended] = false
    end

    context "rp is not allowed to continue on fail" do
      it "rp doesn't have a custom fail message" do
        stub_api_idp_list_for_registration(default_idps)
        set_transaction(WITH_NON_CONTINUE_ON_FAILED_REGISTRATION_RP)

        expect(subject).to render_template(:non_continue_on_failed_registration_rp)
      end

      it "rp has a custom fail message" do
        set_transaction(WITH_CUSTOM_FAILED_REGISTRATION_MESSAGE_RP)

        expect(subject).to render_template(:custom_failed_registration)
      end
    end

    it "continue on failed registration view when rp is allowed to continue on failed" do
      set_transaction(WITH_CONTINUE_ON_FAILED_REGISTRATION_RP)

      expect(subject).to render_template(:continue_on_failed_registration_rp)
    end
  end
end
