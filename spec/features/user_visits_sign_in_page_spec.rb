require 'feature_helper'
require 'api_test_helper'

RSpec.describe 'user selects an IDP on the sign in page' do
  def given_api_requests_have_been_mocked!
    stub_federation
    stub_session_select_idp_request(encrypted_entity_id)
    stub_session_idp_authn_request(originating_ip, location, false)
    stub_request(:get, INTERNAL_PIWIK.url).with(query: hash_including({}))
  end

  def then_custom_variable_reported_for_sign_in
    piwik_request = {
      '_cvar' => "{\"1\":[\"RP\",\"#{transaction_analytics_description}\"]}",
      'action_name' => 'The No option was selected on the introduction page',
    }
    expect(a_piwik_request.with(query: hash_including(piwik_request))).to have_been_made.once
  end

  def given_im_on_the_sign_in_page(locale = 'en')
    set_session_and_session_cookies!
    visit "/#{I18n.t('routes.sign_in', locale: locale)}"
  end

  def when_i_select_an_idp
    click_button(idp_display_name)
  end

  def a_piwik_request
    a_request(:get, INTERNAL_PIWIK.url)
  end

  def then_im_at_the_idp
    expect(page).to have_current_path(location)
    expect(page).to have_content("SAML Request is 'a-saml-request'")
    expect(page).to have_content("relay state is 'a-relay-state'")
    expect(page).to have_content("registration is 'false'")
    expect(cookie_value('verify-front-journey-hint')).to_not be_nil
    expect(a_request(:put, session_api_uri(default_session_id, SessionProxy::SELECT_IDP_SUFFIX))
             .with(body: { 'entityId' => idp_entity_id, 'originatingIp' => originating_ip, 'registration' => false })).to have_been_made.once
    expect(a_request(:get, session_api_uri(default_session_id, SessionProxy::IDP_AUTHN_REQUEST_SUFFIX))
             .with(headers: { 'X_FORWARDED_FOR' => originating_ip })).to have_been_made.once
    piwik_request = {
      '_cvar' => "{\"3\":[\"SIGNIN_IDP\",\"#{idp_display_name}\"]}",
      'action_name' => 'Sign In - ' + idp_display_name,
    }
    expect(a_piwik_request.with(query: hash_including(piwik_request))).to have_been_made.once
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
      then_custom_variable_reported_for_sign_in
      expect_any_instance_of(SignInController).to receive(:select_idp_ajax).and_call_original
      when_i_select_an_idp
      then_im_at_the_idp
      and_the_language_hint_is_set
      and_the_hints_are_not_set
      expect(page.get_rack_session_key('selected_idp')).to eql('entity_id' => idp_entity_id, 'simple_id' => 'stub-idp-one')
    end
  end

  context 'with JS disabled', js: false do
    it 'shows the IDP tag line' do
      given_api_requests_have_been_mocked!
      given_im_on_the_sign_in_page
      expect(page).to have_css('img[alt="IDCorp: a really cool identity provider"]')
      expect(page).to have_css('img[alt="Bob’s Identity Service"]')
    end

    it 'will display the interstitial page and on submit will redirect the user to IDP' do
      page.set_rack_session(transaction_simple_id: 'test-rp')
      given_api_requests_have_been_mocked!
      given_im_on_the_sign_in_page
      then_custom_variable_reported_for_sign_in
      when_i_select_an_idp
      then_im_at_the_interstitial_page
      when_i_choose_to_continue
      then_im_at_the_idp
      expect(page.get_rack_session_key('selected_idp')).to eql('entity_id' => idp_entity_id, 'simple_id' => 'stub-idp-one')
    end

    it 'will display the interstitial page in welsh' do
      page.set_rack_session(transaction_simple_id: 'test-rp')
      given_api_requests_have_been_mocked!
      given_im_on_the_sign_in_page 'cy'
      then_custom_variable_reported_for_sign_in
      when_i_select_an_idp
      then_im_at_the_interstitial_page 'cy'
    end

    it 'rejects unrecognised entity ids' do
      page.set_rack_session(transaction_simple_id: 'test-rp')
      given_api_requests_have_been_mocked!
      given_im_on_the_sign_in_page

      first('input[value="http://idcorp.com"]', visible: false).set('bob')
      when_i_select_an_idp

      expect(page).to have_content(I18n.translate('errors.page_not_found.title'))
      expect(a_piwik_request).to have_not_been_made
      expect(page.get_rack_session['selected_idp']).to be_nil
    end
  end
end
