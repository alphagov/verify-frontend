require "feature_helper"
require "api_test_helper"
require "piwik_test_helper"

RSpec.describe "User interaction results in a post to POLICY_PROXY idp_select with ab test value" do
  let(:current_ab_test_value) { "sign_in_hint_control" }
  let(:originating_ip) { "<PRINCIPAL IP ADDRESS COULD NOT BE DETERMINED>" }
  let(:encrypted_entity_id) { "an-encrypted-entity-id" }
  let(:location) { "/test-idp-request-endpoint" }
  let(:idp_entity_id) { "http://idcorp.com" }
  let(:idp_display_name) { "IDCorp" }
  let(:select_idp_stub_request) {
    stub_session_select_idp_request(
      encrypted_entity_id,
      PolicyEndpoints::PARAM_SELECTED_ENTITY_ID => idp_entity_id, PolicyEndpoints::PARAM_PRINCIPAL_IP => originating_ip,
      PolicyEndpoints::PARAM_REGISTRATION => false, PolicyEndpoints::PARAM_REQUESTED_LOA => "LEVEL_2",
      PolicyEndpoints::PARAM_ANALYTICS_SESSION_ID => piwik_session_id, PolicyEndpoints::PARAM_JOURNEY_TYPE => "single-idp",
      PolicyEndpoints::PARAM_VARIANT => current_ab_test_value
    )
  }
  before(:each) do
    allow_any_instance_of(UserCookiesPartialController)
      .to receive(:ab_test_with_alternative_name).and_return(current_ab_test_value)
  end
  let(:set_single_idp_journey_cookie) {
    visit "/test-single-idp-journey"
    click_button "initiate-single-idp-post"
  }
  context "sign in to Idp" do
    def given_api_requests_have_been_mocked!
      stub_session_select_idp_request(encrypted_entity_id)
      stub_session_idp_authn_request(originating_ip, location, false)
    end

    def given_the_piwik_request_has_been_stubbed
      @stub_piwik_journey_request = stub_piwik_journey_type_request("REGISTRATION", "The user started a registration journey", "LEVEL_2")
    end

    def given_im_on_the_sign_in_page(locale = "en")
      set_session_and_session_cookies!(cookie_hash: create_cookie_hash_with_piwik_session)
      stub_api_idp_list_for_sign_in
      visit "/#{t('routes.sign_in', locale: locale)}"
    end

    def given_im_on_the_sign_in_page_from_test_rp_with_custom_hint
      set_session_and_session_cookies!(cookie_hash: create_cookie_hash_with_piwik_session)
      stub_api_idp_list_for_sign_in
      page.set_rack_session(transaction_simple_id: "test-rp-custom-hint")
      visit "/#{t('routes.sign_in', locale: 'en')}"
    end

    def when_i_select_an_idp
      # There may be multiple identical buttons due to the journey hint
      # so we can"t use "click_button"
      all(:button, idp_display_name)[0].click
    end

    def when_i_click_start_now
      click_link("begin-registration-route")
    end

    def then_im_at_the_idp
      expect(page).to have_current_path(location)
      expect(page).to have_content("SAML Request is 'a-saml-request'")
      expect(page).to have_content("relay state is 'a-relay-state'")
      expect(page).to have_content("registration is 'false'")
      expect(cookie_value("verify-front-journey-hint")).to_not be_nil

      expect(a_request(:post, policy_api_uri(select_idp_endpoint(default_session_id)))
               .with(body: { PolicyEndpoints::PARAM_SELECTED_ENTITY_ID => idp_entity_id, PolicyEndpoints::PARAM_PRINCIPAL_IP => originating_ip,
                             PolicyEndpoints::PARAM_REGISTRATION => false, PolicyEndpoints::PARAM_REQUESTED_LOA => "LEVEL_2",
                             PolicyEndpoints::PARAM_ANALYTICS_SESSION_ID => piwik_session_id, PolicyEndpoints::PARAM_JOURNEY_TYPE => nil,
                             PolicyEndpoints::PARAM_VARIANT => current_ab_test_value })).to have_been_made.once
      expect(a_request(:get, saml_proxy_api_uri(authn_request_endpoint(default_session_id)))
               .with(headers: { "X_FORWARDED_FOR" => originating_ip })).to have_been_made.once
    end

    def and_piwik_was_sent_a_signin_event
      expect(stub_piwik_request("action_name" => "Sign In - #{idp_display_name}")).to have_been_made.once
    end

    def and_piwik_was_sent_a_signin_hint_followed_event
      expect(stub_piwik_request("action_name" => "Sign In - #{idp_display_name} - Hint Followed")).to have_been_made.once
    end

    def and_piwik_was_sent_a_signin_hint_ignored_event
      expect(stub_piwik_request("action_name" => "Sign In - #{idp_display_name} - Hint Ignored")).to have_been_made.once
    end

    def then_piwik_was_sent_a_journey_hint_shown_event_for(idp_name)
      expect(stub_piwik_request("action_name" => "Sign In Journey Hint Shown - #{idp_name}")).to have_been_made.once
    end

    def and_the_language_hint_is_set
      expect(page).to have_content("language hint was 'en'")
    end

    def and_the_hints_are_not_set
      expect(page).to have_content("hints are ''")
    end

    def then_im_at_the_interstitial_page(locale = "en")
      expect(page).to have_current_path("/#{t('routes.redirect_to_idp_sign_in', locale: locale)}")
    end

    def when_i_choose_to_continue
      click_button t("navigation.continue")
    end

    def expect_to_have_updated_the_piwik_journey_type_variable
      expect(@stub_piwik_journey_request).to have_been_made.once
    end

    let(:idp_entity_id) { "http://idcorp.com" }
    let(:idp_display_name) { "IDCorp" }
    let(:transaction_analytics_description) { "analytics description for test-rp" }
    let(:body) {
      [
        { "simpleId" => "stub-idp-zero", "entityId" => "idp-zero" },
        { "simpleId" => "stub-idp-one", "entityId" => idp_entity_id },
        { "simpleId" => "stub-idp-two", "entityId" => "idp-two" },
        { "simpleId" => "stub-idp-three", "entityId" => "idp-three" },
        { "simpleId" => "stub-idp-four", "entityId" => "idp-four" },
      ]
    }
    let(:location) { "/test-idp-request-endpoint" }
    let(:originating_ip) { "<PRINCIPAL IP ADDRESS COULD NOT BE DETERMINED>" }
    let(:encrypted_entity_id) { "an-encrypted-entity-id" }

    context "with JS enabled", js: true do
      it "will redirect the user to the IDP" do
        page.set_rack_session(transaction_simple_id: "test-rp")
        given_api_requests_have_been_mocked!
        given_im_on_the_sign_in_page
        expect_any_instance_of(SignInController).to receive(:select_idp_ajax).and_call_original
        when_i_select_an_idp
        then_im_at_the_idp
        and_piwik_was_sent_a_signin_event
        and_the_language_hint_is_set
        and_the_hints_are_not_set
        expect(page.get_rack_session_key("selected_provider")["identity_provider"]).to include("entity_id" => idp_entity_id, "simple_id" => "stub-idp-one", "levels_of_assurance" => %w(LEVEL_2))
      end

      context "with a valid idp-hint cookie" do
        before :each do
          set_journey_hint_cookie("http://idcorp.com", "SUCCESS")
        end

        it "will redirect the user to the hinted IDP" do
          page.set_rack_session(transaction_simple_id: "test-rp")
          given_api_requests_have_been_mocked!
          given_im_on_the_sign_in_page
          then_piwik_was_sent_a_journey_hint_shown_event_for(idp_display_name)
          expect_any_instance_of(SignInController).to receive(:select_idp_ajax).and_call_original
          when_i_select_an_idp
          then_im_at_the_idp
          and_piwik_was_sent_a_signin_hint_followed_event
          and_the_language_hint_is_set
          and_the_hints_are_not_set
          expect(page.get_rack_session_key("selected_provider")["identity_provider"]).to include("entity_id" => idp_entity_id, "simple_id" => "stub-idp-one", "levels_of_assurance" => %w(LEVEL_2))
        end
      end

      context "with a different valid idp-hint cookie" do
        before :each do
          set_journey_hint_cookie("other-entity-id", "SUCCESS")
        end

        hinted_idp_name = "Bob’s Identity Service"

        it "will redirect the user to a non-hinted IDP if hint ignored" do
          page.set_rack_session(transaction_simple_id: "test-rp")
          given_api_requests_have_been_mocked!
          given_im_on_the_sign_in_page
          then_piwik_was_sent_a_journey_hint_shown_event_for(hinted_idp_name)
          expect(page).to have_text "You can use an identity account you set up with any of these companies:"
          expect(page).to have_text "The last certified company used on this device was #{hinted_idp_name}."
          expect(page).to have_button("Select #{hinted_idp_name}", count: 2)

          expect_any_instance_of(SignInController).to receive(:select_idp_ajax).and_call_original
          when_i_select_an_idp
          then_im_at_the_idp
          and_piwik_was_sent_a_signin_hint_ignored_event
          and_the_language_hint_is_set
          and_the_hints_are_not_set
          expect(page.get_rack_session_key("selected_provider")["identity_provider"]).to include("entity_id" => idp_entity_id, "simple_id" => "stub-idp-one", "levels_of_assurance" => %w(LEVEL_2))
        end
      end
    end
  end

  context "continue to your IDP page" do
    context "javascript disabled" do
      before(:each) do
        set_session_and_session_cookies!(cookie_hash: create_cookie_hash_with_piwik_session)
        stub_transactions_for_single_idp_list
        stub_api_idp_list_for_single_idp_journey
      end

      it "includes the appropriate feedback source, page title and piwik custom variable" do
        set_single_idp_journey_cookie
        visit "/continue-to-your-idp"

        expect(page).to have_current_path("/continue-to-your-idp")
        expect(page).to have_title t("hub.single_idp_journey.title", display_name: idp_display_name)
        expect_feedback_source_to_be(page, "CONTINUE_TO_YOUR_IDP_PAGE", "/continue-to-your-idp")
        piwik_custom_variable_single_idp_journey = "{\"index\":3,\"name\":\"JOURNEY_TYPE\",\"value\":\"SINGLE_IDP\",\"scope\":\"visit\"}"
        expect(page).to have_content(piwik_custom_variable_single_idp_journey)
      end

      it "supports the welsh language" do
        set_single_idp_journey_cookie
        visit "/parhau-ich-idp"

        expect(page).to have_title t("hub.single_idp_journey.title", locale: :cy, display_name: "Welsh IDCorp")
        expect(page).to have_css "html[lang=cy]"
      end

      it "should show the user the start page if the cookie is missing" do
        visit "/continue-to-your-idp"

        expect(page).to have_content t("hub.start.heading")
      end

      it "goes to 'redirect-to-idp' page on submit" do
        set_single_idp_journey_cookie
        visit "/continue-to-your-idp"

        select_idp_stub_request
        stub_session_idp_authn_request(originating_ip, location, false)

        click_button t("hub.single_idp_journey.continue_button", display_name: idp_display_name)

        expect(page).to have_current_path(redirect_to_single_idp_path)
        expect(select_idp_stub_request).to have_been_made.once
        expect(stub_piwik_request("action_name" => "Single IDP selected - #{idp_display_name}")).to have_been_made.once
      end
    end

    context "with JS enabled", js: true do
      def single_idp_session
        {
            transaction_simple_id: "test-rp-noc3",
            start_time: start_time_in_millis,
            verify_session_id: default_session_id,
            requested_loa: "LEVEL_2",
            transaction_entity_id: "some-other-entity-id",
            selected_answers: { device_type: { device_type_other: true } },
        }
      end

      before(:each) do
        set_session_and_session_cookies!(cookie_hash: create_cookie_hash_with_piwik_session, session: single_idp_session)
        stub_transactions_for_single_idp_list
        stub_api_idp_list_for_single_idp_journey("some-other-entity-id")
        visit "/test-single-idp-journey"
        # javascript driver needs a redirect to a real page
        fill_in("serviceId", with: "some-other-entity-id")
        click_button "initiate-single-idp-post"
      end

      it "will redirect the user to the IDP on Continue" do
        visit "/continue-to-your-idp"
        select_idp_stub_request
        stub_session_idp_authn_request(originating_ip, location, false)
        expect_any_instance_of(SingleIdpJourneyController).to receive(:continue_ajax).and_call_original

        click_button t("hub.single_idp_journey.continue_button", display_name: idp_display_name)
        expect(stub_piwik_request("action_name" => "Single IDP selected - #{idp_display_name}")).to have_been_made.once
        expect(page).to have_current_path(location)
        expect(page).to have_content("SAML Request is 'a-saml-request'")
        expect(page).to have_content("relay state is 'a-relay-state'")
        expect(page).to have_content("registration is 'false'")
        expect(page).to have_content("language hint was 'en'")
        expect(page).to have_content("single IDP journey uuid is ")
        expect(select_idp_stub_request).to have_been_made.once
      end
    end
  end

  context "redirect to warning" do
    let(:selected_answers) { { "phone" => { "mobile_phone" => true, "smart_phone" => true }, "documents" => { "passport" => true } } }
    let(:given_an_idp_with_no_display_data) {
      set_selected_idp_in_session(entity_id: idp_entity_id, simple_id: "stub-idp-x")
      page.set_rack_session(
        selected_idp_was_recommended: true,
        selected_answers: selected_answers,
      )
    }
    let(:given_a_session_with_document_answers) {
      set_selected_idp_in_session(entity_id: idp_entity_id, simple_id: "stub-idp-one")
      page.set_rack_session(
        selected_idp_was_recommended: true,
        selected_answers: selected_answers,
      )
    }
    let(:given_a_session_with_a_hints_disabled_idp) {
      set_selected_idp_in_session(entity_id: idp_entity_id, simple_id: "stub-idp-two")
      page.set_rack_session(
        selected_idp_was_recommended: true,
        selected_answers: selected_answers,
      )
    }
    let(:given_a_session_with_non_recommended_idp) {
      set_selected_idp_in_session(entity_id: idp_entity_id, simple_id: "stub-idp-one")
      page.set_rack_session(
        selected_idp_was_recommended: false,
        selected_answers: selected_answers,
      )
    }
    let(:given_a_session_with_no_document_answers) {
      set_selected_idp_in_session(entity_id: "http://idpnodocs.com", simple_id: "stub-idp-no-docs")
      page.set_rack_session(
        selected_idp_was_recommended: true,
        selected_answers: { phone: { mobile_phone: true, smart_phone: true }, documents: {} },
      )
    }
    let(:given_a_session_with_non_uk_id_document_answers) {
      set_selected_idp_in_session(entity_id: "http://idpwithnonukid.com", simple_id: "stub-idp-four")
      page.set_rack_session(
        selected_idp_was_recommended: true,
        selected_answers: { phone: { mobile_phone: true, smart_phone: true }, documents: { non_uk_id_document: true } },
      )
    }
    let(:select_idp_stub_request) {
      stub_session_select_idp_request(
        encrypted_entity_id,
        PolicyEndpoints::PARAM_SELECTED_ENTITY_ID => idp_entity_id, PolicyEndpoints::PARAM_PRINCIPAL_IP => originating_ip,
        PolicyEndpoints::PARAM_REGISTRATION => true, PolicyEndpoints::PARAM_REQUESTED_LOA => "LEVEL_2",
        PolicyEndpoints::PARAM_ANALYTICS_SESSION_ID => piwik_session_id, PolicyEndpoints::PARAM_JOURNEY_TYPE => nil,
        PolicyEndpoints::PARAM_VARIANT => current_ab_test_value
      )
    }
    before(:each) do
      stub_api_idp_list_for_registration
      session = default_session.merge(user_segments: %w(test-segment))
      set_session_and_session_cookies!(cookie_hash: create_cookie_hash_with_piwik_session, session: session)
    end

    it "goes to 'redirect-to-idp' page on submit" do
      given_a_session_with_document_answers

      visit "/redirect-to-idp-warning"

      select_idp_stub_request
      stub_session_idp_authn_request(originating_ip, location, false)

      piwik_registration_virtual_page = stub_piwik_idp_registration(
        "IDCorp",
        selected_answers: selected_answers,
        recommended: true,
        segments: %w(test-segment),
      )

      click_button t("hub.redirect_to_idp_warning.continue_website", display_name: t("idps.stub-idp-one.name"))

      expect(page).to have_current_path(redirect_to_idp_register_path)
      expect(select_idp_stub_request).to have_been_made.once
      expect(piwik_registration_virtual_page).to have_been_made.once
      expect(cookie_value("verify-front-journey-hint")).to_not be_nil
    end

    it "goes to 'redirect-to-idp' page on submit for non-recommended idp" do
      given_a_session_with_non_recommended_idp

      visit "/redirect-to-idp-warning"

      select_idp_stub_request
      stub_session_idp_authn_request(originating_ip, location, false)

      piwik_registration_virtual_page = stub_piwik_idp_registration("IDCorp", selected_answers: selected_answers, segments: %w(test-segment))

      click_button t("hub.redirect_to_idp_warning.continue_website", display_name: t("idps.stub-idp-one.name"))

      expect(page).to have_current_path(redirect_to_idp_register_path)
      expect(select_idp_stub_request).to have_been_made.once
      expect(piwik_registration_virtual_page).to have_been_made.once
      expect(cookie_value("verify-front-journey-hint")).to_not be_nil
    end

    it "includes the recommended text when selection is a recommended idp" do
      given_a_session_with_document_answers
      visit "/redirect-to-idp-warning"

      expect(page.body).to have_content t("hub.redirect_to_idp_warning.continue_website", display_name: "IDCorp")
      expect(page.body).to include t("hub.redirect_to_idp_warning.queue_warning_html", idp: "IDCorp")
    end
  end

  context "resume registration page" do
    let(:service_name) { "test GOV.UK Verify user journeys" }
    let(:rp_entity_id) { "http://www.test-rp.gov.uk/SAML2/MD" }
    let(:piwik_custom_variable_resuming_journey) { "{\"index\":3,\"name\":\"JOURNEY_TYPE\",\"value\":\"RESUMING\",\"scope\":\"visit\"}" }
    let(:select_idp_stub_request) {
      stub_session_select_idp_request(
        encrypted_entity_id,
        PolicyEndpoints::PARAM_SELECTED_ENTITY_ID => idp_entity_id, PolicyEndpoints::PARAM_PRINCIPAL_IP => originating_ip,
        PolicyEndpoints::PARAM_REGISTRATION => false, PolicyEndpoints::PARAM_REQUESTED_LOA => "LEVEL_2",
        PolicyEndpoints::PARAM_ANALYTICS_SESSION_ID => piwik_session_id, PolicyEndpoints::PARAM_JOURNEY_TYPE => "resuming",
        PolicyEndpoints::PARAM_VARIANT => current_ab_test_value
      )
    }

    before(:each) do
      set_session_and_session_cookies!(cookie_hash: create_cookie_hash_with_piwik_session)
      stub_api_idp_list_for_registration
      stub_api_idp_list_for_sign_in
      set_selected_idp_in_session(entity_id: idp_entity_id, simple_id: "stub-idp-one")
      stub_translations
      stub_transaction_details
    end

    context "has a cookie containing a PENDING state and valid IDP identifiers" do
      it "displays correct text and button" do
        set_journey_hint_cookie(idp_entity_id, "PENDING", "en", rp_entity_id)
        visit "/resume-registration"

        expect(page).to have_content t("hub.paused_registration.resume.intro", service_name: service_name, display_name: idp_display_name)
        expect(page).to have_content t("hub.paused_registration.resume.heading", display_name: idp_display_name)
        expect(page).to have_button t("hub.paused_registration.resume.continue", display_name: idp_display_name)
        expect(page).to have_content t("hub.paused_registration.resume.alternative_other_ways", service_name: service_name)

        expect(page).to have_content(piwik_custom_variable_resuming_journey)
      end
    end

    context "has a cookie containing a non pending state and a RESUMELINK section with a valid IDP " do
      it "displays correct text and button" do
        set_journey_hint_cookie(idp_entity_id, "SUCCESS", "en", rp_entity_id, "stub-idp-one")
        visit "/resume-registration"

        expect(page).to have_content t("hub.paused_registration.resume.intro", service_name: service_name, display_name: idp_display_name)
        expect(page).to have_content t("hub.paused_registration.resume.heading", display_name: idp_display_name)
        expect(page).to have_button t("hub.paused_registration.resume.continue", display_name: idp_display_name)
        expect(page).to have_content t("hub.paused_registration.resume.alternative_other_ways", service_name: service_name)

        expect(page).to have_content(piwik_custom_variable_resuming_journey)
      end
    end

    context "has a cookie containing a pending state for a different IDP and a RESUMELINK link section with a valid IDP " do
      it "displays correct text and button for RESUMELINK IDP" do
        set_journey_hint_cookie("a-different-entity-id", "PENDING", "en", rp_entity_id, "stub-idp-one")
        visit "/resume-registration"

        expect(page).to have_content t("hub.paused_registration.resume.intro", service_name: service_name, display_name: idp_display_name)
        expect(page).to have_content t("hub.paused_registration.resume.heading", display_name: idp_display_name)
        expect(page).to have_button t("hub.paused_registration.resume.continue", display_name: idp_display_name)
        expect(page).to have_content t("hub.paused_registration.resume.alternative_other_ways", service_name: service_name)

        expect(page).to have_content(piwik_custom_variable_resuming_journey)
      end
    end

    context "clicks continue to IDP with JS disabled" do
      it "goes to 'redirect-to-idp' page on submit" do
        set_journey_hint_cookie(idp_entity_id, "PENDING", "en", rp_entity_id)
        visit "/resume-registration"
        select_idp_stub_request
        stub_session_idp_authn_request(originating_ip, location, false)

        click_button t("hub.paused_registration.resume.continue", display_name: idp_display_name)

        expect(page).to have_current_path(redirect_to_idp_resume_path)
        expect(select_idp_stub_request).to have_been_made.once
        expect(stub_piwik_request("action_name" => "Resume - #{idp_display_name}")).to have_been_made.once
      end
    end

    context "clicks continue to IDP with JS enabled", js: true do
      it "will redirect the user to the IDP on Continue" do
        set_journey_hint_cookie(idp_entity_id, "PENDING", "en", rp_entity_id)
        visit "/resume-registration"
        select_idp_stub_request
        stub_session_idp_authn_request(originating_ip, location, false)
        expect_any_instance_of(PausedRegistrationController).to receive(:resume_with_idp_ajax).and_call_original

        click_button t("hub.paused_registration.resume.continue", display_name: idp_display_name)
        expect(stub_piwik_request("action_name" => "Resume - #{idp_display_name}")).to have_been_made.once
        expect(page).to have_current_path(location)
        expect(page).to have_content("SAML Request is 'a-saml-request'")
        expect(page).to have_content("relay state is 'a-relay-state'")
        expect(page).to have_content("registration is 'false'")
        expect(page).to have_content("language hint was 'en'")
        expect(select_idp_stub_request).to have_been_made.once
      end
    end
  end
end
