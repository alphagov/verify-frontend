require "rails_helper"
require "controller_helper"
require "api_test_helper"
require "piwik_test_helper"

describe ProveIdentityController do
  before(:each) do
    set_session_and_cookies_with_loa("LEVEL_2")
  end

  it "renders prove identity page" do
    get :index, params: { locale: "en" }
    expect(subject).to render_template(:prove_identity)
  end

  context "when restarting eIDAS journey" do
    let(:stub_restart_journey_request) { stub_restart_journey }

    it "will not restart journey when it is not eIDAS" do
      set_selected_idp "stub-idp"

      get :retry_eidas_journey, params: { locale: "en" }

      expect(subject).to redirect_to(prove_identity_path)
      expect(stub_restart_journey_request).to have_not_been_made
    end

    it "will restart journey when country selected" do
      set_selected_country "stub-country"
      stub_restart_journey

      get :retry_eidas_journey, params: { locale: "en" }

      expect(subject).to redirect_to(prove_identity_path)
      expect(stub_restart_journey_request).to have_been_made.once
      expect(session[:selected_provider]).to be_nil
    end
  end
end
