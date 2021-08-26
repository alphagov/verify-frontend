require "rails_helper"
require "controller_helper"
require "spec_helper"
require "models/display/viewable_identity_provider"

describe ConfirmationController do
  subject { get :matching_journey, params: { locale: "en" } }

  context "user has selected an idp" do
    before(:each) do
      set_selected_idp("entity_id" => "http://idcorp.com", "simple_id" => "stub-idp-one", "levels_of_assurance" => [LevelOfAssurance::LOA1, LevelOfAssurance::LOA2])
    end

    it "renders the confirmation LOA1 template when LEVEL_1 is the requested LOA" do
      set_session_and_cookies_with_loa(LevelOfAssurance::LOA1)
      expect(subject).to render_template(:confirmation)
    end

    it "renders the confirmation LOA2 template when LEVEL_2 is the requested LOA" do
      set_session_and_cookies_with_loa(LevelOfAssurance::LOA2)
      expect(subject).to render_template(:confirmation)
    end
  end

  context "user has no selected IDP in session" do
    it "should raise a WarningLevelError" do
      set_session_and_cookies_with_loa(LevelOfAssurance::LOA1)
      expect(Rails.logger).to receive(:warn).with(kind_of(Errors::WarningLevelError)).once
      get :matching_journey, params: { locale: "en" }
      expect(response).to have_http_status(500)
    end
  end
end
