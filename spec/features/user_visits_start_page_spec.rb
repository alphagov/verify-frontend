require 'feature_helper'
require 'api_test_helper'
require 'cookie_names'
require 'piwik_test_helper'

RSpec.describe 'When the user visits the start page' do
  it 'will display the start page in English' do
    set_session_and_session_cookies!
    visit '/start'
    expect(page).to have_content t('hub.start.heading')
    expect(page).to have_css 'html[lang=en]'
    expect_feedback_source_to_be(page, 'START_PAGE', '/start')
  end

  it 'will display the start page in Welsh' do
    set_session_and_session_cookies!
    visit '/dechrau'
    expect(page).to have_content t('hub.start.heading', locale: :cy)
    expect(page).to have_css 'html[lang=cy]'
  end

  it 'will not automatically disable the continue button on submit' do
    set_session_and_session_cookies!
    visit '/start'
    expect(page).to_not have_css '#next-button[data-disable-with]'
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

  context 'with a valid idp-hint cookie' do
    let(:idp_entity_id) { 'http://idcorp.com' }
    let(:encrypted_entity_id) { 'an-encrypted-entity-id' }
    let(:idp_display_name) { 'IDCorp' }
    let(:location) { '/test-idp-request-endpoint' }
    let(:originating_ip) { '<PRINCIPAL IP ADDRESS COULD NOT BE DETERMINED>' }

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
    end

    before :each do
      stub_api_idp_list_for_sign_in
      page.set_rack_session(transaction_simple_id: 'test-rp')
      set_session_and_session_cookies!
      set_journey_hint_cookie('http://idcorp.com', 'SUCCESS')
    end

    it 'will render a suggested IDP' do
      visit '/start'
      expect(page).to have_text 'You can also:'
      expect(page).to have_text "The last certified company used on this device was #{idp_display_name}."
      expect(page).to have_button("Continue with #{idp_display_name}")
      expect(page).to have_css 'meta[name="verify|title"][content="Start - with hint (IDCorp) - GOV.UK Verify - GOV.UK - LEVEL_2"]', visible: false
      expect_feedback_source_to_be(page, 'START_PAGE_WITH_HINT', '/start')
    end

    it 'will redirect the user to the hinted IDP' do
      visit '/start'
      stub_session_idp_authn_request(originating_ip, location, false)
      expect_any_instance_of(SignInController).to receive(:select_idp).and_call_original
      stub_session_select_idp_request(encrypted_entity_id)
      click_button 'Continue with'
      expect(stub_piwik_request('action_name' => "Sign In - #{idp_display_name} - Followed Hint")).to have_been_made.once
      expect(page.get_rack_session_key('selected_idp')).to include('entity_id' => idp_entity_id, 'simple_id' => 'stub-idp-one', 'levels_of_assurance' => %w(LEVEL_2))
    end

    it 'will redirect the user to the hinted IDP with JS enabled', js: true do
      visit '/start'
      stub_session_idp_authn_request(originating_ip, location, false)
      expect_any_instance_of(SignInController).to receive(:select_idp_ajax).and_call_original
      stub_session_select_idp_request(encrypted_entity_id)
      click_button 'Continue with'
      then_im_at_the_idp
      expect(stub_piwik_request('action_name' => "Sign In - #{idp_display_name} - Followed Hint")).to have_been_made.once
      expect(page.get_rack_session_key('selected_idp')).to include('entity_id' => idp_entity_id, 'simple_id' => 'stub-idp-one', 'levels_of_assurance' => %w(LEVEL_2))
    end

    it 'will redirect the user to the about page when the registration option is clicked' do
      visit '/start'
      click_link t('hub.start.with_hint.create_option')
      expect(page).to have_content t('hub.about.verify_is_a_service')
      expect(page).to have_current_path(about_path, only_path: true)
      expect(
        stub_piwik_journey_type_request(
          'REGISTRATION',
          'The user started a registration journey',
          'LEVEL_2'
        )
      ).to have_been_made.once
    end

    it 'will redirect the user to the sign-in page when the sign-in option is clicked' do
      visit '/start'
      click_link t('hub.start.with_hint.signin_option')
      expect(page).to have_content t('hub.signin.heading')
      expect(page).to have_current_path(sign_in_path, only_path: true)
      expect(
        stub_piwik_journey_type_request(
          'SIGN_IN',
          'The user started a sign-in journey',
          'LEVEL_2'
        )
      ).to have_been_made.once
    end
  end
  context 'with an invalid idp-hint cookie' do
    let(:idp_display_name) { 'IDCorp' }

    before :each do
      stub_api_idp_list_for_sign_in
      page.set_rack_session(transaction_simple_id: 'test-rp')
      set_session_and_session_cookies!
      set_journey_hint_cookie('http://non-existing-idp.com', 'SUCCESS')
    end

    it 'will not render a suggested IDP' do
      visit '/start'
      expect(page).not_to have_text 'You can also:'
      expect(page).not_to have_text "The last certified company used on this device was #{idp_display_name}."
      expect(page).not_to have_button("Continue with #{idp_display_name}")
      expect(page).not_to have_css 'meta[name="verify|title"][content="Start - with hint (IDCorp) - GOV.UK Verify - GOV.UK - LEVEL_2"]', visible: false
      expect(page).to have_content t('hub.start.heading')
      expect_feedback_source_to_be(page, 'START_PAGE', '/start')
    end
  end
end
