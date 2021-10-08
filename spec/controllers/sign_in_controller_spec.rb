require "rails_helper"
require "controller_helper"
require "api_test_helper"
require "piwik_test_helper"
require "select_idp_examples"

describe SignInController do
  context "With Expiring IDPs" do
    before(:each) do
      set_session_and_cookies_with_loa("LEVEL_1")
      stub_piwik_report_sign_in_idp_selection("IDCorp", "LEVEL_1")
      stub_api_idp_list_for_sign_in([{ "simpleId" => "stub-idp-one",
                                       "entityId" => "http://idcorp.com",
                                       "levelsOfAssurance" => %w(LEVEL_1),
                                       "provideAuthenticationUntil" => (1.months + 1.day + 1.hour).from_now.to_s },
                                     { "simpleId" => "stub-idp-two",
                                       "entityId" => "http://idcorp-two.com",
                                       "levelsOfAssurance" => %w(LEVEL_1),
                                       "provideAuthenticationUntil" => (1.months - 1.day).from_now.to_s }])
    end

    it "will redirect to the selected IDP before warning threshold" do
      stub_session_idp_authn_request
      stub_session_select_idp_request("http://idcorp.com")
      stub_piwik_report_user_idp_attempt("IDCorp", "test-rp", loa: "LEVEL_1")

      post :select_idp, params: { locale: "en", entity_id: "http://idcorp.com" }
      expect(session[:selected_provider].simple_id).to eq("stub-idp-one")
      expect(subject).to render_template "shared/redirect_to_idp"
    end

    it "will redirect to the warning path for the selected IDP after warning threshold" do
      stub_session_select_idp_request("http://idcorp-two.com")
      stub_piwik_report_user_idp_attempt("Bob’s Identity Service", "test-rp", loa: "LEVEL_1")

      post :select_idp, params: { locale: "en", entity_id: "http://idcorp-two.com" }
      expect(session[:selected_provider].simple_id).to eq("stub-idp-two")
      expect(subject).to redirect_to(sign_in_warning_path)
    end
  end

  context "With IDPs expiring in less than 2 hours" do
    before(:each) do
      stub_api_idp_list_for_sign_in([{ "simpleId" => "stub-idp-one",
                                       "entityId" => "http://idcorp.com",
                                       "levelsOfAssurance" => %w(LEVEL_1),
                                       "provideAuthenticationUntil" => 1.hours.from_now.to_s },
                                     { "simpleId" => "stub-idp-two",
                                       "entityId" => "http://idcorp-two.com",
                                       "levelsOfAssurance" => %w(LEVEL_1) }])
      set_session_and_cookies_with_loa("LEVEL_1")
    end

    it "will have one available IDP" do
      expect(subject.identity_providers_available_for_sign_in.length).to eq(1)
    end

    it "will have one unavilable IDP" do
      expect(subject.identity_providers_disconnected_for_sign_in.length).to eq(1)
    end
  end

  context "Without Expiring IDPs" do
    before(:each) do
      set_session_and_cookies_with_loa("LEVEL_1")
      stub_api_idp_list_for_sign_in([{ "simpleId" => "stub-idp-one",
                                       "entityId" => "http://idcorp.com",
                                       "levelsOfAssurance" => %w(LEVEL_1) },
                                     { "simpleId" => "stub-idp-two",
                                       "entityId" => "http://idcorp-two.com",
                                       "levelsOfAssurance" => %w(LEVEL_1) },
                                     { "simpleId" => "stub-idp-broken",
                                       "entityId" => "http://idcorp-broken.com",
                                       "levelsOfAssurance" => %w(LEVEL_1),
                                       "temporarilyUnavailable" => true }])
    end

    context "#index" do
      it "will render the index page" do
        get :index, params: { locale: "en" }
        expect(subject).to render_template(:index)
        expect(response).to have_http_status(:ok)
      end

      it "will render the index page with invalid cookie" do
        cookies.encrypted[CookieNames::VERIFY_FRONT_JOURNEY_HINT] = { entity_id: "some-nonsense-idp-entity-id" }.to_json
        get :index, params: { locale: "en" }
        expect(subject).to render_template(:index)
        expect(response).to have_http_status(:ok)
      end
    end

    context "#select_idp" do
      before(:each) do
        stub_piwik_report_sign_in_idp_selection("IDCorp", "LEVEL_1")
        stub_piwik_report_user_idp_attempt("IDCorp", "test-rp", loa: "LEVEL_1")
      end

      context "without IDP journey hint cookie" do
        it "will leave the session param nil if no journey hint was shown" do
          stub_session_idp_authn_request
          stub_session_select_idp_request("http://idcorp.com")

          post :select_idp, params: { locale: "en", entity_id: "http://idcorp.com" }
          expect(session[:user_followed_journey_hint]).to be_nil
        end

        it "will have one temporarily unavailable IDP" do
          expect(subject.identity_providers_unavailable_for_sign_in.length).to eq(1)
        end

        it "will have two available IDPs" do
          expect(subject.identity_providers_available_for_sign_in.length).to eq(2)
        end
      end

      context "with IDP journey hint cookie" do
        before :each do
          stub_session_idp_authn_request
          cookies.encrypted[CookieNames::VERIFY_FRONT_JOURNEY_HINT] = { entity_id: "http://idcorp.com", SUCCESS: "http://idcorp.com" }.to_json
        end

        it "will set the session param true if user followed the journey hint" do
          stub_piwik_report_user_idp_attempt("IDCorp", "test-rp", loa: "LEVEL_1", hint_present: true, hint_followed: true)
          stub_piwik_report_sign_in_idp_selection("IDCorp", "LEVEL_1", hint: :followed)
          stub_session_select_idp_request("http://idcorp.com")

          post :select_idp, params: { locale: "en", entity_id: "http://idcorp.com" }
          expect(session[:user_followed_journey_hint]).to be true
        end

        it "will set the session param false if user ignored the journey hint" do
          stub_piwik_report_user_idp_attempt("Bob’s Identity Service", "test-rp", loa: "LEVEL_1", hint_present: true)
          stub_piwik_report_sign_in_idp_selection("Bob’s Identity Service", "LEVEL_1", hint: :ignored)
          other_entity_id = "http://idcorp-two.com"
          stub_session_select_idp_request(other_entity_id)

          post :select_idp, params: { locale: "en", entity_id: other_entity_id }
          expect(session[:user_followed_journey_hint]).to be false
        end
      end
    end
  end

  context "select IDP" do
    include_examples "select_idp", JourneyType::SIGN_IN, :select_idp,
                     :stub_api_idp_list_for_sign_in, :stub_piwik_report_sign_in_idp_selection, :report_sign_in_idp_selection
  end
end
