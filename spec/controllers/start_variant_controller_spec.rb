require "rails_helper"
require "controller_helper"
require "api_test_helper"
require "piwik_test_helper"

describe StartVariantController do
  before(:each) do
    set_session_and_cookies_with_loa("LEVEL_2")
  end

  context "when rendering start page" do
    let(:stub_restart_journey_request) { stub_restart_journey }

    it "renders LOA2 start page if service is level 2" do
      get :index, params: { locale: "en" }
      expect(subject).to render_template(:start)
      expect(stub_restart_journey_request).to have_not_been_made
    end

    it "will not restart journey when IDP selected" do
      set_selected_idp "stub-idp"

      get :index, params: { locale: "en" }
      expect(subject).to render_template(:start)
      expect(stub_restart_journey_request).to have_not_been_made
    end

    it "will restart journey when it is not Verify" do
      set_selected_country "stub-country"
      stub_restart_journey

      get :index, params: { locale: "en" }

      expect(subject).to render_template(:start)
      expect(stub_restart_journey_request).to have_been_made.once
      expect(session[:selected_provider]).to be_nil
    end
  end

  context "when form is valid" do
    it "will redirect to sign in page when selection is false" do
      stub_piwik_request = stub_piwik_journey_type_request(
        "SIGN_IN",
        "The user started a sign-in journey",
        "LEVEL_2",
      )
      post :request_post, params: { locale: "en", start_form: { selection: false } }
      expect(subject).to redirect_to("/sign-in")
      expect(stub_piwik_request).to have_been_made.once
    end

    it "will redirect to about page when selection is true" do
      stub_piwik_request = stub_piwik_journey_type_request(
        "REGISTRATION",
        "The user started a registration journey",
        "LEVEL_2",
      )
      post :request_post, params: { locale: "en", start_form: { selection: true } }
      expect(subject).to redirect_to("/about")
      expect(stub_piwik_request).to have_been_made.once
    end
  end

  context "when form is invalid" do
    it "renders itself" do
      post :request_post, params: { locale: "en" }
      expect(subject).to render_template(:start)
      expect(flash[:errors]).not_to be_empty
    end
  end

  it "will redirect to about page when selection is registration" do
    stub_piwik_request = stub_piwik_journey_type_request(
      "REGISTRATION",
      "The user started a registration journey",
      "LEVEL_2",
    )
    get :register, params: { locale: "en" }
    expect(subject).to redirect_to("/about")
    expect(stub_piwik_request).to have_been_made.once
  end

  context "when sign-in hint is present" do
    it "renders the hint when IDP valid" do
      cookies.encrypted[CookieNames::VERIFY_FRONT_JOURNEY_HINT] = {
        "SUCCESS" => "http://idcorp.com",
      }.to_json
      stub_api_idp_list_for_sign_in

      get :index, params: { locale: "en" }
      expect(subject).to render_template("shared/sign_in_hint", "layouts/main_layout")
    end

    it "renders the normal start page if IDP is invalid" do
      cookies.encrypted[CookieNames::VERIFY_FRONT_JOURNEY_HINT] = {
        "SUCCESS" => "invalid",
      }.to_json
      stub_api_idp_list_for_sign_in

      get :index, params: { locale: "en" }
      expect(subject).to render_template(:start, "layouts/slides")
    end

    it "renders the normal start page if success is missing" do
      cookies.encrypted[CookieNames::VERIFY_FRONT_JOURNEY_HINT] = {
        "ATTEMPT" => "http://idcorp.com",
      }.to_json
      stub_api_idp_list_for_sign_in

      get :index, params: { locale: "en" }
      expect(subject).to render_template(:start, "layouts/slides")
    end

    it "allows to disregard the hint and deletes the SUCCESS" do
      cookies.encrypted[CookieNames::VERIFY_FRONT_JOURNEY_HINT] = {
        "ATTEMPT" => "http://idcorp.com",
        "SUCCESS" => "http://idcorp.com",
      }.to_json
      stub_api_idp_list_for_sign_in

      expect(FEDERATION_REPORTER).to receive(:report_sign_in_journey_ignored).with(
        a_kind_of(Display::RpDisplayData),
        a_kind_of(ActionDispatch::Request),
        "IDCorp",
        "test-rp",
      )

      get :ignore_hint, params: { locale: "en" }

      cookie_hint = MultiJson.load(cookies.encrypted[CookieNames::VERIFY_FRONT_JOURNEY_HINT])

      expect(subject).to redirect_to start_path
      expect(cookie_hint["ATTEMPT"]).to eq "http://idcorp.com"
      expect(cookie_hint["SUCCESS"]).to be_nil
    end

    it "allows to disregard the hint and does not fail if success does not exist" do
      cookies.encrypted[CookieNames::VERIFY_FRONT_JOURNEY_HINT] = {
        "ATTEMPT" => "http://idcorp.com",
      }.to_json
      stub_api_idp_list_for_sign_in

      expect(FEDERATION_REPORTER).not_to receive(:report_sign_in_journey_ignored)

      get :ignore_hint, params: { locale: "en" }

      cookie_hint = MultiJson.load(cookies.encrypted[CookieNames::VERIFY_FRONT_JOURNEY_HINT])

      expect(subject).to redirect_to start_path
      expect(cookie_hint["ATTEMPT"]).not_to be_nil
      expect(cookie_hint["SUCCESS"]).to be_nil
    end
  end
end
