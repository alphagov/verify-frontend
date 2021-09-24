require "feature_helper"
require "api_test_helper"
require "piwik_test_helper"
require "sign_in_helper"

RSpec.describe "user selects an IDP on the sign in page" do
  def given_api_requests_have_been_mocked!
    stub_session_select_idp_request(encrypted_entity_id)
    stub_session_idp_authn_request(originating_ip, location, false)
  end

  def given_im_on_the_sign_in_page(locale = "en")
    set_session_and_session_cookies!(cookie_hash: create_cookie_hash_with_piwik_session, session: default_session.merge!({ journey_type: "sign-in" }))
    stub_api_idp_list_for_sign_in([{ "simpleId" => "stub-idp-one",
                                      "entityId" => "http://idcorp.com",
                                      "levelsOfAssurance" => %w(LEVEL_2),
                                      "provideAuthenticationUntil" => 10.day.from_now.to_s },
                                   {  "simpleId" => "stub-idp-two",
                                      "entityId" => "http://idcorp-two.com",
                                      "levelsOfAssurance" => %w(LEVEL_2),
                                      "provideAuthenticationUntil" => 10.day.from_now.to_s }])
    visit "/#{t('routes.sign_in', locale: locale)}"
  end

  def when_i_click_start_now
    click_link("begin-registration-route")
  end

  let(:idp_entity_id) { "http://idcorp.com" }
  let(:idp_display_name) { "IDCorp" }
  let(:current_ab_test_value) { "sign_in_hint_control" }
  let(:transaction_analytics_description) { "analytics description for test-rp" }
  let(:location) { "/test-idp-request-endpoint" }
  let(:originating_ip) { "<PRINCIPAL IP ADDRESS COULD NOT BE DETERMINED>" }
  let(:encrypted_entity_id) { "an-encrypted-entity-id" }

  context "with JS enabled", js: true do
    it "will redirect the user to the warning page" do
      given_api_requests_have_been_mocked!
      given_im_on_the_sign_in_page
      expect_any_instance_of(SignInController).to receive(:select_idp_ajax).and_call_original
      click_button t("hub.signin.select_idp", display_name: idp_display_name)
      expect(page).to have_current_path(sign_in_warning_path)
      expect(page).to have_button(t("hub.signin.select_idp", display_name: idp_display_name))
      expect(page).to have_link(t("hub.signin.warning.after_link"), href: begin_registration_path)
      expect(page.get_rack_session_key("selected_provider")["identity_provider"]).to include("entity_id" => idp_entity_id, "simple_id" => "stub-idp-one", "levels_of_assurance" => %w(LEVEL_2))
    end
  end
end
