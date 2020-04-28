require "rails_helper"
require "controller_helper"
require "spec_helper"
require "api_test_helper"

describe PausedRegistrationController do
  let(:valid_rp) { "http://www.test-rp.gov.uk/SAML2/MD" }
  let(:valid_idp) { "http://idcorp.com" }
  let(:valid_idp_simple_id) { "stub-idp-one" }

  before(:each) do
    set_selected_idp("entity_id" => "http://idcorp.com", "simple_id" => "stub-idp-one", "levels_of_assurance" => %w(LEVEL_1 LEVEL_2))
    set_session_and_cookies_with_loa("LEVEL_2", "test-rp")
    stub_api_idp_list_for_registration
    stub_transaction_details
  end

  context "user visits pause page" do
    subject { get :index, params: { locale: "en" } }

    it "renders paused registration page when session is present" do
      expect(subject).to render_template(:with_user_session)
    end

    it "renders paused registration page when cookie is present but no session" do
      session.delete(:selected_provider)

      stub_translations
      stub_api_idp_list_for_sign_in

      front_journey_hint_cookie = {
          STATE: {
              IDP: valid_idp,
              RP: valid_rp,
              STATUS: "PENDING",
          },
      }

      cookies.encrypted[CookieNames::VERIFY_FRONT_JOURNEY_HINT] = front_journey_hint_cookie.to_json

      expect(subject).to render_template(:with_user_session)
    end

    it "renders paused registration without session page when there is no idp selected and no pending cookie" do
      session.delete(:selected_provider)

      stub_translations
      stub_api_idp_list_for_sign_in

      front_journey_hint_cookie = {
          STATE: {
              IDP: valid_idp,
              RP: valid_rp,
              STATUS: "OTHER",
          },
      }

      cookies.encrypted[CookieNames::VERIFY_FRONT_JOURNEY_HINT] = front_journey_hint_cookie.to_json

      expect(subject).to render_template(:without_user_session)
    end

    it "should render paused registration without session page when there is no idp selected" do
      session.delete(:selected_provider)

      expect(subject).to render_template(:without_user_session)
    end
  end

  context "user is directed to a link from an IDP e-mail with a valid IDP simple_id" do
    subject { get :from_resume_link, params: { locale: "en", idp: valid_idp_simple_id } }

    it "renders the resume link paused registration page if valid idp passed" do
      expect(subject).to render_template(:from_resume_link)
    end

    it "redirects to paused page if user has a matching PENDING state in cookie" do
      front_journey_hint_cookie = {
          STATE: {
              IDP: valid_idp,
              RP: valid_rp,
              STATUS: "PENDING",
          },
      }
      cookies.encrypted[CookieNames::VERIFY_FRONT_JOURNEY_HINT] = front_journey_hint_cookie.to_json

      expect(subject).to redirect_to paused_registration_path
    end

    it "renders resume link paused registration page if user has a PENDING state for a different IDP in cookie" do
      front_journey_hint_cookie = {
          STATE: {
              IDP: "other-entity-id",
              RP: valid_rp,
              STATUS: "PENDING",
          },
      }
      cookies.encrypted[CookieNames::VERIFY_FRONT_JOURNEY_HINT] = front_journey_hint_cookie.to_json

      expect(subject).to render_template(:from_resume_link)
    end
  end

  context "user is directed to a resume link from an IDP e-mail with an invalid IDP simple_id" do
    subject { get :from_resume_link, params: { locale: "en", idp: "invalid-simple-id" } }

    it "redirects to start page" do
      expect(subject).to render_template(:without_user_session)
      expect(cookies.encrypted[CookieNames::VERIFY_FRONT_JOURNEY_HINT]).to be_nil
    end
  end

  context "user is redirected to resume page" do
    subject { get :resume, params: { locale: "en" } }

    it "renders resume registration page if session present" do
      front_journey_hint_cookie = {
          STATE: {
              IDP: valid_idp,
              RP: valid_rp,
              STATUS: "PENDING",
          },
      }

      cookies.encrypted[CookieNames::VERIFY_FRONT_JOURNEY_HINT] = front_journey_hint_cookie.to_json
      expect(subject).to render_template(:resume)
    end

    it "renders resume registration page if session present and RESUMELINK cookie present" do
      front_journey_hint_cookie = {
          STATE: {
              IDP: valid_idp,
              RP: valid_rp,
              STATUS: "PENDING",
          },
          RESUMELINK: {
              IDP: "stub-idp-two",
          },
      }

      cookies.encrypted[CookieNames::VERIFY_FRONT_JOURNEY_HINT] = front_journey_hint_cookie.to_json
      expect(subject).to render_template(:resume)
    end

    it "redirects to start page when invalid/disabled IDP present in cookie" do
      front_journey_hint_cookie = {
          STATE: {
              IDP: :'a-non-existent-idp-identifier',
              RP: :valid_rp,
              STATUS: "PENDING",
          },
      }
      cookies.encrypted[CookieNames::VERIFY_FRONT_JOURNEY_HINT] = front_journey_hint_cookie.to_json
      expect(subject).to redirect_to start_path
    end

    it "redirects to start page when invalid RP present in cookie" do
      front_journey_hint_cookie = {
          STATE: {
              IDP: :valid_idp,
              RP: :'we-changed-our-entityID',
              STATUS: "PENDING",
          },
      }
      cookies.encrypted[CookieNames::VERIFY_FRONT_JOURNEY_HINT] = front_journey_hint_cookie.to_json
      expect(subject).to redirect_to start_path
    end

    it "should render error page when user has no session" do
      session.clear

      expect(subject).to render_template(:something_went_wrong)
    end
  end
end
