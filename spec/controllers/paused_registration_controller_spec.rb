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
    idps = [
      { "simpleId" => "stub-idp-one", "entityId" => "http://idcorp.com", "levelsOfAssurance" => %w(LEVEL_2) },
      { "simpleId" => "stub-idp-two", "entityId" => "http://idcorp-two.com", "levelsOfAssurance" => %w(LEVEL_2) },
    ]
    stub_api_idp_list_for_registration(idps)
    stub_api_idp_list_for_sign_in(idps)
    stub_transaction_details
  end

  context "user visits pause page" do
    subject { get :index, params: { locale: "en" } }

    context "with session present" do
      it "renders paused registration page" do
        expect(subject).to render_template(:with_user_session)
      end
    end

    context "with no session" do
      before do
        session.delete(:selected_provider)
        stub_translations
        stub_api_idp_list_for_sign_in
      end

      it "renders paused registration page when cookie is present but no session" do
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
        expect(subject).to render_template(:without_user_session)
      end

      it "should render with session page when it's a sign in journey" do
        front_journey_hint_cookie = {
          STATE: {
            IDP: "http://idcorp-three.com",
            RP: valid_rp,
            STATUS: "PENDING",
            VERIFY_JOURNEY_TYPE: JourneyType::SIGN_IN,
          },
        }

        cookies.encrypted[CookieNames::VERIFY_FRONT_JOURNEY_HINT] = front_journey_hint_cookie.to_json

        expect(subject).to render_template(:with_user_session)
      end

      it "should render IDP no longer providing registrations page when no session, the selected IDP is sign in only, and it's not a sign-in journey" do
        front_journey_hint_cookie = {
          STATE: {
            IDP: "http://idcorp-three.com",
            RP: valid_rp,
            STATUS: "PENDING",
            JOURNEY_TYPE: JourneyType::REGISTRATION,
          },
        }

        cookies.encrypted[CookieNames::VERIFY_FRONT_JOURNEY_HINT] = front_journey_hint_cookie.to_json

        expect(subject).to render_template(:idp_no_longer_providing_registrations)
      end

      it "should raise when IDP not found in registering or sign in IDPs" do
        front_journey_hint_cookie = {
          STATE: {
            IDP: "http://this-should-never-happen.com",
            RP: valid_rp,
            STATUS: "PENDING",
          },
        }

        cookies.encrypted[CookieNames::VERIFY_FRONT_JOURNEY_HINT] = front_journey_hint_cookie.to_json

        expect(subject).to render_template(:something_went_wrong)
      end
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

    it "should render error page when user has no session" do
      session.clear
      expect(subject).to render_template(:something_went_wrong)
    end

    it "redirects user to the start page when invalid/disabled IDP present in cookie" do
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

    it "redirects user to the start page when RP present in cookie but is obsoleted / disabled in config service" do
      front_journey_hint_cookie = {
          STATE: {
              IDP: :valid_idp,
              RP: :'obsolete-rp-our-entityID',
              STATUS: "PENDING",
          },
      }
      stub_missing_transaction_details
      cookies.encrypted[CookieNames::VERIFY_FRONT_JOURNEY_HINT] = front_journey_hint_cookie.to_json

      expect(subject).to redirect_to start_path
    end

    it "redirects user to the start page when RP present in cookie and there is a SESSION_ERROR error" do
      front_journey_hint_cookie = {
        STATE: {
            IDP: :valid_idp,
            RP: :'rp-entityID',
            STATUS: "PENDING",
        },
      }
      error_body = { clientMessage: "Failure", exceptionType: "EXPECTED_SESSION_STARTED_STATE_ACTUAL_IDP_SELECTED_STATE", errorId: "0", Referer: "" }
      stub_missing_transaction_details(body: error_body, status: 400)

      cookies.encrypted[CookieNames::VERIFY_FRONT_JOURNEY_HINT] = front_journey_hint_cookie.to_json
      expect(subject).to redirect_to start_path
    end

    it "redirects user to the start page when RP present in cookie and there is a SESSION_TIMEOUT error" do
      front_journey_hint_cookie = {
        STATE: {
            IDP: :valid_idp,
            RP: :'rp-entityID',
            STATUS: "PENDING",
        },
      }
      error_body = { clientMessage: "Failure", exceptionType: "SESSION_TIMEOUT", errorId: "0", Referer: "" }
      stub_missing_transaction_details(body: error_body, status: 400)

      cookies.encrypted[CookieNames::VERIFY_FRONT_JOURNEY_HINT] = front_journey_hint_cookie.to_json
      expect(subject).to redirect_to start_path
    end
  end

  context "user POSTs to resume_with_idp with invalid session" do
    subject { post :resume_with_idp, params: { locale: "en", entity_id: valid_idp } }

    it "should render error page" do
      stub_api_select_idp
      session.delete("transaction_entity_id")

      expect(subject).to render_template(:something_went_wrong)
    end
  end

  context "user PUTs to resume_with_idp_ajax with invalid session" do
    subject { put :resume_with_idp_ajax, params: { locale: "en", entityId: valid_idp } }

    it "should render error page" do
      stub_api_select_idp
      stub_request(:get, INTERNAL_PIWIK.url).with(query: hash_including({}))
      stub_session_idp_authn_request("127.0.0.1", "idp-location", true)

      session.delete("transaction_entity_id")

      expect(subject).to render_template(:something_went_wrong)
    end
  end
end
