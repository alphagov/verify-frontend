require "rails_helper"
require "controller_helper"
require "api_test_helper"
require "piwik_test_helper"

describe ChooseACountryController do
  before(:each) do |test|
    set_session_and_cookies_with_loa("LEVEL_2")
    set_session_supports_eidas unless test.metadata[:no_eidas]
    stub_countries_list
  end

  context "when choosing a country" do
    let(:stub_restart_journey_request) { stub_restart_journey }

    it "will not restart journey if identity provider not selected" do
      get :choose_a_country, params: { locale: "en" }
      expect(stub_restart_journey_request).to have_not_been_made
      expect(session[:selected_provider]).to be_nil
    end

    it "will not restart journey when country selected" do
      set_selected_country "stub-country"

      get :choose_a_country, params: { locale: "en" }
      expect(stub_restart_journey_request).to have_not_been_made
    end

    it "will restart journey when it is not eIDAS" do
      set_selected_idp "stub-idp"
      stub_restart_journey

      get :choose_a_country, params: { locale: "en" }
      expect(stub_restart_journey_request).to have_been_made.once
      expect(session[:selected_provider]).to be_nil
    end

    it "shows an error if eIDAS is not supported", :no_eidas do
      allow(Rails.logger).to receive(:error)
      allow(Rails.logger).to receive(:warn)
      expect(Rails.logger).not_to receive(:error)
      expect(Rails.logger).to receive(:warn).with("Transaction does not support Eidas")
      get :choose_a_country, params: { locale: "en" }
    end
  end
end
