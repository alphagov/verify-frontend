require "rails_helper"
require "controller_helper"
require "api_test_helper"

describe RedirectToCountryController do
  let(:originating_ip) { "<PRINCIPAL IP ADDRESS COULD NOT BE DETERMINED>" }
  before(:each) do
    stub_countries_list
    session[:transaction_supports_eidas] = true
    set_session_and_cookies_with_loa("LEVEL_2")
    stub_session_country_authn_request(originating_ip, redirect_to_country_path, false)
  end

  context "#choose_a_country_submit" do
    it "will redirect to the path for the selected country" do
      stub_select_country_request("YY")

      post :choose_a_country_submit, params: { locale: "en", country: "YY" }

      expect(session[:selected_provider].simple_id).to eq("YY")
      expect(subject).to render_template(:index)
    end

    it "will redirect to an error page when the country is unrecognised" do
      stub_select_country_request("INVALID_COUNTRY")

      post :choose_a_country_submit, params: { locale: "en", country: "INVALID_COUNTRY" }

      expect(session[:selected_provider]).to be_nil
      expect(response).to have_http_status(:internal_server_error)
      expect(subject).to render_template(:something_went_wrong)
    end
  end
end
