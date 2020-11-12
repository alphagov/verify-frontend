require "feature_helper"
require "api_test_helper"
require "piwik_test_helper"
require "sign_in_helper"

RSpec.describe "user selects an IDP on the sign in page" do
  def given_api_requests_have_been_mocked!
    stub_session_select_idp_request(encrypted_entity_id)
    stub_session_idp_authn_request(originating_ip, location, false)
  end

  def given_the_piwik_request_has_been_stubbed
    @stub_piwik_journey_request = stub_piwik_journey_type_request("REGISTRATION", "The user started a registration journey", "LEVEL_2")
  end

  def given_im_on_the_sign_in_page(locale = "en")
    set_session_and_session_cookies!(cookie_hash: create_cookie_hash_with_piwik_session, session: default_session.merge!({ journey_type: "sign-in" }))
    stub_api_idp_list_for_sign_in
    visit "/#{t('routes.sign_in', locale: locale)}"
  end

  def given_im_on_the_sign_in_page_from_test_rp_with_custom_hint
    set_session_and_session_cookies!(cookie_hash: create_cookie_hash_with_piwik_session)
    stub_api_idp_list_for_sign_in
    page.set_rack_session(transaction_simple_id: "test-rp-custom-hint")
    visit "/#{t('routes.sign_in', locale: 'en')}"
  end

  def when_i_click_start_now
    click_link("begin-registration-route")
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
  let(:current_ab_test_value) { "sign_in_hint_control" }
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
      given_api_requests_have_been_mocked!
      given_im_on_the_sign_in_page
      expect_any_instance_of(SignInController).to receive(:select_idp_ajax).and_call_original
      when_i_select_an_idp idp_display_name
      then_im_at_the_idp
      and_piwik_was_sent_a_signin_event
      and_the_language_hint_is_set
      and_the_hints_are_not_set
      expect(page.get_rack_session_key("selected_provider")["identity_provider"]).to include("entity_id" => idp_entity_id, "simple_id" => "stub-idp-one", "levels_of_assurance" => %w(LEVEL_2))
    end

    it "will redirect the user to the IDP when there is an ab_test_value" do
      allow_any_instance_of(UserCookiesPartialController)
       .to receive(:ab_test_with_alternative_name).and_return(current_ab_test_value)
      given_api_requests_have_been_mocked!
      given_im_on_the_sign_in_page
      expect_any_instance_of(SignInController).to receive(:select_idp_ajax).and_call_original
      when_i_select_an_idp idp_display_name
      then_im_at_the_idp(ab_value: current_ab_test_value)
      and_piwik_was_sent_a_signin_event
      and_the_language_hint_is_set
      and_the_hints_are_not_set
      expect(page.get_rack_session_key("selected_provider")["identity_provider"]).to include("entity_id" => idp_entity_id, "simple_id" => "stub-idp-one", "levels_of_assurance" => %w(LEVEL_2))
    end

    it "will redirect the user to the about page of the registration journey and update the Piwik Custom Variables" do
      stub_api_idp_list_for_registration
      given_api_requests_have_been_mocked!
      given_the_piwik_request_has_been_stubbed
      given_im_on_the_sign_in_page
      when_i_click_start_now
      expect(page).to have_title t("hub.about.title")
      expect_to_have_updated_the_piwik_journey_type_variable
    end

    it "will not render a suggested IDP" do
      given_api_requests_have_been_mocked!
      given_im_on_the_sign_in_page
      expect(page).not_to have_text "The last certified company used on this device was"
      expect(page).not_to have_text "You can use an identity account you set up with any certified company in the past:"
    end

    context "with an invalid idp-hint cookie" do
      before :each do
        set_journey_hint_cookie("http://not-a-valid-idp.com", "SUCCESS")
      end

      it "will not render a suggested IDP" do
        given_api_requests_have_been_mocked!
        given_im_on_the_sign_in_page
        expect(page).not_to have_text "The last certified company used on this device was"
        expect(page).not_to have_text "You can use an identity account you set up with any certified company in the past:"
      end
    end

    context "with a valid idp-hint cookie" do
      before :each do
        set_journey_hint_cookie("http://idcorp.com", "SUCCESS")
      end

      it "will render a suggested IDP" do
        given_api_requests_have_been_mocked!
        given_im_on_the_sign_in_page
        expect(page).to have_text "You can use an identity account you set up with any of these companies:"
        expect(page).to have_text "The last certified company used on this device was #{idp_display_name}."
        expect(page).to have_button("Select #{idp_display_name}", count: 2)
        then_piwik_was_sent_a_journey_hint_shown_event_for(idp_display_name)
      end

      it "will redirect the user to the hinted IDP" do
        given_api_requests_have_been_mocked!
        given_im_on_the_sign_in_page
        then_piwik_was_sent_a_journey_hint_shown_event_for(idp_display_name)
        expect_any_instance_of(SignInController).to receive(:select_idp_ajax).and_call_original
        when_i_select_an_idp idp_display_name
        then_im_at_the_idp
        and_piwik_was_sent_a_signin_hint_followed_event
        and_the_language_hint_is_set
        and_the_hints_are_not_set
        expect(page.get_rack_session_key("selected_provider")["identity_provider"]).to include("entity_id" => idp_entity_id, "simple_id" => "stub-idp-one", "levels_of_assurance" => %w(LEVEL_2))
      end
    end

    context "with a different valid idp-hint cookie" do
      before :each do
        set_journey_hint_cookie("http://idcorp-two.com", "SUCCESS")
      end

      hinted_idp_name = "Bob’s Identity Service"

      it "will redirect the user to a non-hinted IDP if hint ignored" do
        given_api_requests_have_been_mocked!
        given_im_on_the_sign_in_page
        then_piwik_was_sent_a_journey_hint_shown_event_for(hinted_idp_name)
        expect(page).to have_text "You can use an identity account you set up with any of these companies:"
        expect(page).to have_text "The last certified company used on this device was #{hinted_idp_name}."
        expect(page).to have_button("Select #{hinted_idp_name}", count: 2)

        expect_any_instance_of(SignInController).to receive(:select_idp_ajax).and_call_original
        when_i_select_an_idp idp_display_name
        then_im_at_the_idp
        and_piwik_was_sent_a_signin_hint_ignored_event
        and_the_language_hint_is_set
        and_the_hints_are_not_set
        expect(page.get_rack_session_key("selected_provider")["identity_provider"]).to include("entity_id" => idp_entity_id, "simple_id" => "stub-idp-one", "levels_of_assurance" => %w(LEVEL_2))
      end
    end

    context "with an idp-hint cookie for a disconnected IDP" do
      hinted_idp_name = "Disconnected IDP"

      before :each do
        set_journey_hint_cookie("http://idcorp-disconnected.com", "SUCCESS")
      end

      it "will tell the user the hinted IDP is disconnected" do
        given_api_requests_have_been_mocked!
        given_im_on_the_sign_in_page

        expect(page).to have_text "#{hinted_idp_name} is no longer a part of GOV.UK Verify"
        expect(page).to have_text "If you have an identity account with #{hinted_idp_name}, you’ll need to verify your identity with another company."
        expect(page).to_not have_button("Select #{hinted_idp_name}")
      end

      it "will show the user service-specific text when the hinted IDP is disconnected" do
        given_api_requests_have_been_mocked!
        given_im_on_the_sign_in_page_from_test_rp_with_custom_hint

        expect(page).to have_text "#{hinted_idp_name} is no longer a part of GOV.UK Verify"
        expect(page).to have_text "An alternative hint warning."
        expect(page).to_not have_button("Select #{hinted_idp_name}")
      end
    end
  end
end
