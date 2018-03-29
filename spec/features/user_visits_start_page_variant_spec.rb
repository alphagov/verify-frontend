require 'feature_helper'
require 'api_test_helper'
require 'cookie_names'
require 'piwik_test_helper'

RSpec.describe 'When the user visits the start page on short questions variant' do
  def given_api_requests_have_been_mocked!
    stub_session_select_idp_request(encrypted_entity_id)
    stub_session_idp_authn_request(originating_ip, location, false)
    stub_transactions_list
  end

  def given_the_piwik_request_has_been_stubbed
    @stub_piwik_journey_request = stub_piwik_journey_type_request('REGISTRATION', 'The user started a registration journey', 'LEVEL_2')
  end

  def given_im_on_the_start_variant_page(locale = 'en')
    set_cookies_and_ab_test_cookie!('short_questions_v2' => 'short_questions_v2_variant')
    set_session_and_session_cookies!
    stub_api_idp_list_for_sign_in
    visit "/#{t('routes.start', locale: locale)}"
  end

  def when_i_select_an_idp
    click_button(idp_display_name)
  end

  def then_piwik_reports_as_sign_in
    expect(stub_piwik_journey_type_request('SIGN_IN', 'The user started a sign-in journey', 'LEVEL_2')).to have_been_made.once
  end

  def when_i_click_set_up_an_online_identity
    click_link('begin-registration-path')
  end

  def then_im_at_the_idp
    expect(page).to have_current_path(location)
    expect(page).to have_content("SAML Request is 'a-saml-request'")
    expect(page).to have_content("relay state is 'a-relay-state'")
    expect(page).to have_content("registration is 'false'")
    expect(cookie_value('verify-front-journey-hint')).to_not be_nil
    expect(a_request(:post, policy_api_uri(select_idp_endpoint(default_session_id)))
             .with(body: { PolicyEndpoints::PARAM_SELECTED_ENTITY_ID => idp_entity_id, PolicyEndpoints::PARAM_PRINCIPAL_IP => originating_ip,
                           PolicyEndpoints::PARAM_REGISTRATION => false, PolicyEndpoints::PARAM_REQUESTED_LOA => 'LEVEL_2' })).to have_been_made.once
    expect(a_request(:get, saml_proxy_api_uri(authn_request_endpoint(default_session_id)))
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
    expect(page).to have_current_path("/#{t('routes.redirect_to_idp_sign_in', locale: locale)}")
  end

  def when_i_choose_to_continue
    click_button t('navigation.continue')
  end

  def expect_to_have_updated_the_piwik_journey_type_variable
    expect(@stub_piwik_journey_request).to have_been_made.once
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

  context 'when there is no error' do
    before(:each) do
      set_session_and_session_cookies!
      set_cookies_and_ab_test_cookie!('short_questions_v2' => 'short_questions_v2_variant')
      stub_api_idp_list_for_sign_in
    end

    it 'will display the start page in English' do
      visit '/start'
      expect(page).to have_content t('hub.start.ab_test_short_questions_heading')
      expect(page).to have_css 'html[lang=en]'
      expect_feedback_source_to_be(page, 'START_PAGE_SHORT_QUESTIONS_VARIANT', '/start')
    end

    it 'will display the start page in Welsh' do
      visit '/dechrau'
      expect(page).to have_content t('hub.start.ab_test_short_questions_heading', locale: :cy)
      expect(page).to have_css 'html[lang=cy]'
    end
  end

  context 'with JS disabled', js: false do
    it 'will display list of IDP logos' do
      page.set_rack_session(transaction_simple_id: 'test-rp')
      given_im_on_the_start_variant_page
      expect(page).to have_css("input[src*='/small-short-questions-variant/stub-idp-one.png']")
    end

    it 'will redirect the user on selection of the IDP' do
      page.set_rack_session(transaction_simple_id: 'test-rp')
      given_api_requests_have_been_mocked!
      given_im_on_the_start_variant_page
      expect_any_instance_of(StartVariantController).to receive(:select_idp).and_call_original
      when_i_select_an_idp
      then_piwik_reports_as_sign_in
      then_im_at_the_interstitial_page
      when_i_choose_to_continue
      then_im_at_the_idp
      and_the_language_hint_is_set
      and_the_hints_are_not_set
      expect(page.get_rack_session_key('selected_idp')).to include('entity_id' => idp_entity_id, 'simple_id' => 'stub-idp-one', 'levels_of_assurance' => %w(LEVEL_2))
    end

    it 'will redirect the user to the select-documents of the registration journey and update the Piwik Custom Variables' do
      page.set_rack_session(transaction_simple_id: 'test-rp', requested_loa: 'LEVEL_2')
      given_api_requests_have_been_mocked!
      given_the_piwik_request_has_been_stubbed
      given_im_on_the_start_variant_page
      when_i_click_set_up_an_online_identity
      expect(page).to have_title t('hub.select_documents.ab_test_short_questions_title_photo_documents')
      expect_to_have_updated_the_piwik_journey_type_variable
    end
  end

  context 'with JS enabled', js: true do
    it 'will redirect the user on selection of the IDP' do
      page.set_rack_session(transaction_simple_id: 'test-rp')
      given_api_requests_have_been_mocked!
      given_im_on_the_start_variant_page
      expect_any_instance_of(StartVariantController).to receive(:select_idp_ajax).and_call_original
      when_i_select_an_idp
      then_im_at_the_idp
      and_the_language_hint_is_set
      and_the_hints_are_not_set
      expect(page.get_rack_session_key('selected_idp')).to include('entity_id' => idp_entity_id, 'simple_id' => 'stub-idp-one', 'levels_of_assurance' => %w(LEVEL_2))
    end
  end

  context 'when there is an error' do
    before(:each) do
      stub_transactions_list
    end

    it 'will display the no cookies error when all cookies are missing' do
      allow(Rails.logger).to receive(:info)
      expect(Rails.logger).to receive(:info).with("No session cookies can be found").at_least(:once)
      visit "/start"
      expect(page).to have_content t('errors.no_cookies.enable_cookies')
      expect(page).to have_http_status :forbidden
      expect(page).to have_link 'feedback', href: '/feedback?feedback-source=COOKIE_NOT_FOUND_PAGE'
      expect(page).to have_link "register for an identity profile", href: "http://localhost:50130/test-rp"
    end

    it 'will display the generic error when start time is missing from session' do
      set_session!(transaction_simple_id: 'test-rp', verify_session_id: 'my-session-id-cookie', identity_providers: [{ 'simple_id' => 'stub-idp-one' }])
      cookie_hash = create_cookie_hash
      allow(Rails.logger).to receive(:info)
      expect(Rails.logger).to receive(:info).with('start_time not in session').at_least(:once)
      set_cookies!(cookie_hash)
      visit '/start'
      expect(page).to have_content t('errors.something_went_wrong.heading')
      expect(page).to have_http_status :internal_server_error
      expect(page).to have_link 'feedback', href: '/feedback?feedback-source=ERROR_PAGE'
    end

    it 'will display the generic error when the session cookie is missing' do
      cookie_hash = create_cookie_hash
      allow(Rails.logger).to receive(:info)
      expect(Rails.logger).to receive(:info).with("The following cookies are missing: [#{CookieNames::SESSION_COOKIE_NAME}]").at_least(:once)
      set_cookies!(cookie_hash.except(CookieNames::SESSION_COOKIE_NAME))
      visit '/start'
      expect(page).to have_content t('errors.something_went_wrong.heading')
      expect(page).to have_http_status :internal_server_error
      expect(page).to have_link 'feedback', href: '/feedback?feedback-source=ERROR_PAGE'
    end

    it 'will display the generic error when the session id cookie is missing' do
      cookie_hash = create_cookie_hash
      allow(Rails.logger).to receive(:info)
      expect(Rails.logger).to receive(:info).with("The following cookies are missing: [#{CookieNames::SESSION_ID_COOKIE_NAME}]").at_least(:once)
      set_cookies!(cookie_hash.except(CookieNames::SESSION_ID_COOKIE_NAME))
      visit '/start'
      expect(page).to have_content t('errors.something_went_wrong.heading')
      expect(page).to have_http_status :internal_server_error
      expect(page).to have_link 'feedback', href: '/feedback?feedback-source=ERROR_PAGE'
    end

    it 'will display the something went wrong page when the session id is missing' do
      set_session_cookies!
      set_session!(transaction_simple_id: 'test-rp', start_time: start_time_in_millis)
      visit '/start'
      expect(page).to have_content t('errors.something_went_wrong.heading')
      expect(page).to have_http_status :internal_server_error
      expect(page).to have_link 'feedback', href: '/feedback?feedback-source=ERROR_PAGE'
    end

    it 'will display the something went wrong page when the session id does not match the cookie value' do
      set_session_cookies!
      set_session!(transaction_simple_id: 'test-rp', start_time: start_time_in_millis, verify_session_id: 'a mismatched value')
      visit '/start'
      expect(page).to have_content t('errors.something_went_wrong.heading')
      expect(page).to have_http_status :bad_request
      expect(page).to have_link 'feedback', href: '/feedback?feedback-source=ERROR_PAGE'
    end

    it 'will display the timeout expiration error when the session start cookie is old' do
      session_id_cookie = create_cookie_hash[CookieNames::SESSION_ID_COOKIE_NAME]
      allow(Rails.logger).to receive(:info)
      expect(Rails.logger).to receive(:info).with("session \"#{session_id_cookie}\" has expired").at_least(:once)
      set_session_and_session_cookies!
      expired_start_time = 2.hours.ago.to_i * 1000
      page.set_rack_session(start_time: expired_start_time)
      visit '/start'
      expect(page).to have_content t('hub.transaction_list.title')
      expect(page).to have_link 'register for an identity profile', href: 'http://localhost:50130/test-rp'
      expect(page).to have_http_status :bad_request
      expect(page).to have_link 'feedback', href: '/feedback?feedback-source=EXPIRED_ERROR_PAGE'
    end
  end

  it 'will not allow robots to index' do
    set_session_and_session_cookies!
    visit '/start'
    expect(page).to have_css('meta[name="robots"][content="noindex"]', visible: false)
  end
end
