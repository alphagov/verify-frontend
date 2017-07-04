require 'feature_helper'
require 'api_test_helper'
require 'piwik_test_helper'

RSpec.describe 'user selects an IDP on the sign in page' do
  def given_api_requests_have_been_mocked!
    stub_session_select_idp_request(encrypted_entity_id)
    stub_session_idp_authn_request(originating_ip, location, false)
    @user_action_piwik_request = stub_piwik_request(
      '_cvar' => "{\"1\":[\"RP\",\"#{transaction_analytics_description}\"]}",
      'action_name' => 'The No option was selected on the introduction page',
      )
    @loa_requested_piwik_request = stub_piwik_report_loa_requested('LEVEL_2')
  end

  def then_custom_variables_are_reported_to_piwik
    expect(@user_action_piwik_request).to have_been_made.once
    expect(@loa_requested_piwik_request).to have_been_made.once
  end

  def given_im_on_the_sign_in_page(locale = 'en')
    set_session_and_session_cookies!
    stub_api_idp_list
    visit "/#{I18n.t('routes.sign_in', locale: locale)}"
  end

  def when_i_select_an_idp
    click_button(idp_display_name)
  end

  def then_im_at_the_idp
    expect(page).to have_current_path(location)
    expect(page).to have_content("SAML Request is 'a-saml-request'")
    expect(page).to have_content("relay state is 'a-relay-state'")
    expect(page).to have_content("registration is 'false'")
    expect(cookie_value('verify-front-journey-hint')).to_not be_nil
    expect(a_request(:put, api_uri(select_idp_endpoint(default_session_id)))
             .with(body: { 'entityId' => idp_entity_id, 'originatingIp' => originating_ip, 'registration' => false })).to have_been_made.once
    expect(a_request(:get, api_uri(idp_authn_request_endpoint(default_session_id)))
             .with(headers: { 'X_FORWARDED_FOR' => originating_ip })).to have_been_made.once
    expect(stub_piwik_request('action_name' => "Sign In - #{idp_display_name}")).to have_been_made.once
  end

  def and_the_language_hint_is_set
    expect(page).to have_content("language hint was 'en'")
  end

  def and_the_hints_are_not_set
    expect(page).to have_content("hints are ''")
  end

  def then_im_at_the_interstitial_page(locale = 'en')
    expect(page).to have_current_path("/#{I18n.t('routes.redirect_to_idp', locale: locale)}")
  end

  def when_i_choose_to_continue
    click_button('Continue')
  end

  let(:idp_entity_id) { 'http://idcorp.com' }
  let(:idp_display_name) { 'IDCorp' }
  let(:transaction_analytics_description) { 'analytics description for test-rp' }
  let(:body) {
    [
      { 'simpleId' => 'stub-idp-zero', 'entityId' => 'idp-zero' },
      { 'simpleId' => 'stub-idp-one', 'entityId' => idp_entity_id },
      { 'simpleId' => 'stub-idp-two', 'entityId' => 'idp-two' },
      { 'simpleId' => 'stub-idp-three', 'entityId' => 'idp-three' },
      { 'simpleId' => 'stub-idp-four', 'entityId' => 'idp-four' }
    ]
  }
  let(:location) { '/test-idp-request-endpoint' }
  let(:originating_ip) { '<PRINCIPAL IP ADDRESS COULD NOT BE DETERMINED>' }
  let(:encrypted_entity_id) { 'an-encrypted-entity-id' }

  context 'with JS enabled', js: true do
    it 'will redirect the user to the IDP' do
      page.set_rack_session(transaction_simple_id: 'test-rp')
      given_api_requests_have_been_mocked!
      given_im_on_the_sign_in_page
      then_custom_variables_are_reported_to_piwik
      expect_any_instance_of(SignInController).to receive(:select_idp_ajax).and_call_original
      when_i_select_an_idp
      then_im_at_the_idp
      and_the_language_hint_is_set
      and_the_hints_are_not_set
      expect(page.get_rack_session_key('selected_idp')).to include('entity_id' => idp_entity_id, 'simple_id' => 'stub-idp-one', 'levels_of_assurance' => %w(LEVEL_1 LEVEL_2))
    end
  end
end
