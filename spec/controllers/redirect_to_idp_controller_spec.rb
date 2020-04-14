require "rails_helper"
require "controller_helper"
require "api_test_helper"
require "piwik_test_helper"

describe RedirectToIdpController do
  before :each do
    stub_request(:get, INTERNAL_PIWIK.url).with(query: hash_including({}))
    set_session_and_cookies_with_loa("LEVEL_2")
    session[:selected_idp_was_recommended] = [true, false].sample
  end

  context "single idp journey without cookies" do
    subject { get :single_idp, params: { locale: "en" } }

    it "renders a session error page" do
      cookies.delete CookieNames::VERIFY_SINGLE_IDP_JOURNEY
      expect(subject).to render_template(:session_error)
      subject
    end
  end

  context "continuing to idp with javascript disabled" do
    bobs_identity_service = { "simple_id" => "stub-idp-two",
                              "entity_id" => "http://idcorp.com",
                              "levels_of_assurance" => %w(LEVEL_1 LEVEL_2) }
    before :each do
      stub_session_idp_authn_request("<PRINCIPAL IP ADDRESS COULD NOT BE DETERMINED>", "idp-location", true)
      stub_request(:get, INTERNAL_PIWIK.url).with(query: hash_including({}))
    end

    subject { get :register, params: { locale: "en" } }

    it "reports idp registration details to piwik" do
      bobs_identity_service_idp_name = "Bob’s Identity Service"
      idp_was_recommended = "(recommended)"
      evidence = { driving_licence: true, passport: true }

      set_selected_idp bobs_identity_service
      session[:selected_idp_name] = bobs_identity_service_idp_name
      session[:selected_idp_names] = [bobs_identity_service_idp_name]
      session[:selected_answers] = { "documents" => evidence }
      session[:selected_idp_was_recommended] = idp_was_recommended
      session[:user_segments] = %w(test-segment)

      expect(FEDERATION_REPORTER).to receive(:report_idp_registration)
        .with(current_transaction: a_kind_of(Display::RpDisplayData),
              request: a_kind_of(ActionDispatch::Request),
              idp_name: bobs_identity_service_idp_name,
              idp_name_history: [bobs_identity_service_idp_name],
              evidence: evidence.keys,
              recommended: idp_was_recommended,
              user_segments: %w(test-segment))

      subject
    end

    it "reports idp registration and doesn't error out if idp_was_recommended key not present" do
      bobs_identity_service_idp_name = "Bob’s Identity Service"
      idp_was_recommended = "(idp recommendation key not set)"
      evidence = { driving_licence: true, passport: true }

      set_selected_idp bobs_identity_service
      session[:selected_idp_name] = bobs_identity_service_idp_name
      session[:selected_idp_names] = [bobs_identity_service_idp_name]
      session[:selected_answers] = { "documents" => evidence }
      session[:user_segments] = %w(test-segment)
      session.delete(:selected_idp_was_recommended)

      expect(FEDERATION_REPORTER).to receive(:report_idp_registration)
                                         .with(current_transaction: a_kind_of(Display::RpDisplayData),
                                               request: a_kind_of(ActionDispatch::Request),
                                               idp_name: bobs_identity_service_idp_name,
                                               idp_name_history: [bobs_identity_service_idp_name],
                                               evidence: evidence.keys,
                                               recommended: idp_was_recommended,
                                               user_segments: %w(test-segment))

      subject
    end
  end

  context "reports user idp attempt" do
    describe "#register" do
      bobs_identity_service = { "simple_id" => "stub-idp-two",
                                "entity_id" => "http://idcorp.com",
                                "levels_of_assurance" => %w(LEVEL_1 LEVEL_2) }

      before :each do
        stub_session_idp_authn_request("<PRINCIPAL IP ADDRESS COULD NOT BE DETERMINED>", "idp-location", true)
        stub_request(:get, INTERNAL_PIWIK.url).with(query: hash_including({}))
      end

      subject { get :register, params: { locale: "en" } }

      it "reports idp registration attempt details to piwik" do
        bobs_identity_service_idp_name = "Bob’s Identity Service"

        set_selected_idp bobs_identity_service
        session[:selected_idp_name] = bobs_identity_service_idp_name
        session[:user_segments] = %w(test-segment)
        session[:transaction_simple_id] = "test-rp"
        session[:journey_type] = "registration"
        session[:user_followed_journey_hint] = nil


        expect(FEDERATION_REPORTER).to receive(:report_user_idp_attempt)
                                           .with(current_transaction: a_kind_of(Display::RpDisplayData),
                                                 request: a_kind_of(ActionDispatch::Request),
                                                 idp_name: bobs_identity_service_idp_name,
                                                 user_segments: %w(test-segment),
                                                 transaction_simple_id: "test-rp",
                                                 attempt_number: 1,
                                                 journey_type: "registration",
                                                 hint_followed: nil)
        subject
      end

      it "reports idp second attempt details to piwik" do
        bobs_identity_service_idp_name = "Bob’s Identity Service"

        set_selected_idp bobs_identity_service
        session[:selected_idp_name] = bobs_identity_service_idp_name
        session[:user_segments] = %w(test-segment)
        session[:transaction_simple_id] = "test-rp"
        session[:attempt_number] = 1
        session[:journey_type] = "registration"
        session[:user_followed_journey_hint] = nil


        expect(FEDERATION_REPORTER).to receive(:report_user_idp_attempt)
                                           .with(current_transaction: a_kind_of(Display::RpDisplayData),
                                                 request: a_kind_of(ActionDispatch::Request),
                                                 idp_name: bobs_identity_service_idp_name,
                                                 user_segments: %w(test-segment),
                                                 transaction_simple_id: "test-rp",
                                                 attempt_number: 2,
                                                 journey_type: "registration",
                                                 hint_followed: nil)
        subject
      end
    end

    describe "#sign_in" do
      bobs_identity_service = { "simple_id" => "stub-idp-two",
                                "entity_id" => "http://idcorp.com",
                                "levels_of_assurance" => %w(LEVEL_1 LEVEL_2) }
      bobs_identity_service_idp_name = "Bob’s Identity Service"

      before :each do
        stub_session_idp_authn_request("<PRINCIPAL IP ADDRESS COULD NOT BE DETERMINED>", "idp-location", false)
        stub_request(:get, INTERNAL_PIWIK.url).with(query: hash_including({}))

        set_selected_idp bobs_identity_service
        session[:selected_idp_name] = bobs_identity_service_idp_name
      end

      subject { get :sign_in, params: { locale: "en" } }

      it "reports idp sign in attempt details to piwik when a user has no journey hint" do
        session[:user_segments] = %w(test-segment)
        session[:transaction_simple_id] = "test-rp"
        session[:journey_type] = "sign-in"
        session[:user_followed_journey_hint] = nil

        expect(FEDERATION_REPORTER).to receive(:report_user_idp_attempt)
                                           .with(current_transaction: a_kind_of(Display::RpDisplayData),
                                                 request: a_kind_of(ActionDispatch::Request),
                                                 idp_name: bobs_identity_service_idp_name,
                                                 user_segments: %w(test-segment),
                                                 transaction_simple_id: "test-rp",
                                                 attempt_number: 1,
                                                 journey_type: "sign-in",
                                                 hint_followed: nil)
        subject
      end

      it "reports idp sign in attempt details to piwik when a user does not follow journey hint" do
        session[:user_segments] = %w(test-segment)
        session[:transaction_simple_id] = "test-rp"
        session[:journey_type] = "sign-in"
        session[:user_followed_journey_hint] = false

        expect(FEDERATION_REPORTER).to receive(:report_user_idp_attempt)
                                           .with(current_transaction: a_kind_of(Display::RpDisplayData),
                                                 request: a_kind_of(ActionDispatch::Request),
                                                 idp_name: bobs_identity_service_idp_name,
                                                 user_segments: %w(test-segment),
                                                 transaction_simple_id: "test-rp",
                                                 attempt_number: 1,
                                                 journey_type: "sign-in",
                                                 hint_followed: false)
        expect(FEDERATION_REPORTER).to receive(:report_sign_in_idp_selection_after_journey_hint)
                                           .with(a_kind_of(Display::RpDisplayData),
                                                 a_kind_of(ActionDispatch::Request),
                                                 bobs_identity_service_idp_name,
                                                 false)
        subject
      end

      it "reports idp sign in attempt details to piwik when a user follows the journey hint" do
        session[:user_segments] = %w(test-segment)
        session[:transaction_simple_id] = "test-rp"
        session[:journey_type] = "sign-in"
        session[:user_followed_journey_hint] = true

        expect(FEDERATION_REPORTER).to receive(:report_user_idp_attempt)
                                           .with(current_transaction: a_kind_of(Display::RpDisplayData),
                                                 request: a_kind_of(ActionDispatch::Request),
                                                 idp_name: bobs_identity_service_idp_name,
                                                 user_segments: %w(test-segment),
                                                 transaction_simple_id: "test-rp",
                                                 attempt_number: 1,
                                                 journey_type: "sign-in",
                                                 hint_followed: true)
        expect(FEDERATION_REPORTER).to receive(:report_sign_in_idp_selection_after_journey_hint)
                                           .with(a_kind_of(Display::RpDisplayData),
                                                 a_kind_of(ActionDispatch::Request),
                                                 bobs_identity_service_idp_name,
                                                 true)
        subject
      end
    end

    context "continuing to idp with javascript disabled when signing in" do
      bobs_identity_service = { "simple_id" => "stub-idp-two",
                                "entity_id" => "http://idcorp.com",
                                "levels_of_assurance" => %w(LEVEL_1 LEVEL_2) }
      bobs_identity_service_idp_name = "Bob’s Identity Service"

      before :each do
        stub_session_idp_authn_request("<PRINCIPAL IP ADDRESS COULD NOT BE DETERMINED>", "idp-location", false)
        stub_request(:get, INTERNAL_PIWIK.url).with(query: hash_including({}))

        set_selected_idp bobs_identity_service
        session[:selected_idp_name] = bobs_identity_service_idp_name
      end

      subject { get :sign_in, params: { locale: "en" } }

      it "reports idp selection details to piwik" do
        expect(FEDERATION_REPORTER).to receive(:report_sign_in_idp_selection)
                                           .with(a_kind_of(Display::RpDisplayData),
                                                 a_kind_of(ActionDispatch::Request),
                                                 bobs_identity_service_idp_name)

        subject
      end
    end
  end

  context "signing in with last successful idp" do
    describe "#sign_in_with_last_successful_idp" do
      before :each do
        stub_api_idp_list_for_sign_in([{ "simpleId" => "stub-idp-two",
                                         "entityId" => "http://idcorp-two.com",
                                         "levelsOfAssurance" => %w(LEVEL_1) }])
        set_session_and_cookies_with_loa("LEVEL_1")
        stub_session_select_idp_request("http://idcorp-two.com")
        stub_session_idp_authn_request("<PRINCIPAL IP ADDRESS COULD NOT BE DETERMINED>", "idp-location", true)
      end

      subject { get :sign_in_with_last_successful_idp, params: { locale: "en" } }

      it "sets the selected IdP in Policy and the users session before rendering redirect_to_idp" do
        RedirectToIdpController.any_instance.stub(:flash) { { journey_hint: "idp_stub-idp-two" } }

        expect(POLICY_PROXY).to receive(:select_idp)
                                  .with(
                                    instance_of(String),
                                    "http://idcorp-two.com",
                                    "LEVEL_1",
                                    false,
                                    nil,
                                    "sign-in-last-sucessful-idp",
                                  )

        subject

        expect(response).to have_http_status :ok
        expect(response).to render_template(:redirect_to_idp)
        expect(session[:selected_idp_name]).to eq("Bob’s Identity Service")
      end

      it "returns a 404 if the hint is missing" do
        RedirectToIdpController.any_instance.stub(:flash) { {} }
        expect(POLICY_PROXY).to_not receive(:select_idp)

        subject

        expect(response).to have_http_status :not_found
      end

      it "returns a 404 if the hint is wrong" do
        RedirectToIdpController.any_instance.stub(:flash) { { journey_hint: "idp_sausages" } }
        expect(POLICY_PROXY).to_not receive(:select_idp)

        subject

        expect(response).to have_http_status :not_found
      end
    end
  end
end
