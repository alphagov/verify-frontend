require 'feature_helper'
require 'api_test_helper'
require 'cookie_names'

RSpec.describe 'When the user visits the start page' do
  context 'when session is valid' do
    before(:each) do
      set_session_and_ab_session_cookies!('sign_in_hint' => 'sign_in_hint_variant')
    end

    it 'will display the start page in English on variant' do
      set_session_and_session_cookies!
      visit '/start'
      expect(page).to have_content t('hub.start.heading')
      expect(page).to have_css 'html[lang=en]'
      expect_feedback_source_to_be(page, 'START_PAGE', '/start')
    end

    it 'will display the hint page if an success hint present' do
      set_session_and_session_cookies!
      set_journey_hint_cookie('http://idcorp.com', 'SUCCESS')
      stub_api_idp_list_for_sign_in
      visit '/start'
      expect(page).to have_content t('hub.sign_in_hint.heading')
      expect(page).to have_css 'html[lang=en]'
    end

    it 'will reset the hint and display start page when user ignores the hint' do
      set_session_and_session_cookies!
      set_journey_hint_cookie('http://idcorp.com', 'SUCCESS')
      stub_api_idp_list_for_sign_in
      visit '/start'
      expect(page).to have_content t('hub.sign_in_hint.heading')
      expect(page).to have_css 'html[lang=en]'
      expect(page).to have_current_path '/start'

      click_link t('hub.sign_in_hint.other_way_button')

      expect(page).to have_content t('hub.start.heading')
      expect(page).to have_css 'html[lang=en]'
      expect(page).to have_current_path '/start'
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
      expect(page).to have_link 'feedback', href: '/feedback-landing?feedback-source=COOKIE_NOT_FOUND_PAGE'
      expect(page).to have_link "test GOV.UK Verify user journeys", href: "http://localhost:50130/test-rp"
    end

    it 'will display the generic error when start time is missing from session' do
      cookie_hash = create_cookie_hash
      set_cookies!(cookie_hash)
      set_session!(transaction_simple_id: 'test-rp',
                   verify_session_id: 'my-session-id-cookie',
                   identity_providers: [{ 'simple_id' => 'stub-idp-one' }],
                   transaction_entity_id: 'test-rp')
      allow(Rails.logger).to receive(:info)
      expect(Rails.logger).to receive(:info).with('start_time not in session').at_least(:once)
      visit '/start'
      expect(page).to have_content t('errors.something_went_wrong.heading')
      expect(page).to have_http_status :internal_server_error
      expect(page).to have_link 'feedback', href: '/feedback-landing?feedback-source=ERROR_PAGE'
    end

    it 'will display the generic error when the session cookie is missing' do
      cookie_hash = create_cookie_hash
      allow(Rails.logger).to receive(:info)
      expect(Rails.logger).to receive(:info).with("The following cookies are missing: [#{CookieNames::SESSION_COOKIE_NAME}]").at_least(:once)
      set_cookies!(cookie_hash.except(CookieNames::SESSION_COOKIE_NAME))
      visit '/start'
      expect(page).to have_content t('errors.something_went_wrong.heading')
      expect(page).to have_http_status :internal_server_error
      expect(page).to have_link 'feedback', href: '/feedback-landing?feedback-source=ERROR_PAGE'
    end

    it 'will display the generic error when the session id cookie is missing' do
      cookie_hash = create_cookie_hash
      allow(Rails.logger).to receive(:info)
      expect(Rails.logger).to receive(:info).with("The following cookies are missing: [#{CookieNames::SESSION_ID_COOKIE_NAME}]").at_least(:once)
      set_cookies!(cookie_hash.except(CookieNames::SESSION_ID_COOKIE_NAME))
      visit '/start'
      expect(page).to have_content t('errors.something_went_wrong.heading')
      expect(page).to have_http_status :internal_server_error
      expect(page).to have_link 'feedback', href: '/feedback-landing?feedback-source=ERROR_PAGE'
    end

    it 'will display the something went wrong page when the session id is missing' do
      set_session_cookies!
      set_session!(transaction_simple_id: 'test-rp', start_time: start_time_in_millis)
      visit '/start'
      expect(page).to have_content t('errors.something_went_wrong.heading')
      expect(page).to have_http_status :internal_server_error
      expect(page).to have_link 'feedback', href: '/feedback-landing?feedback-source=ERROR_PAGE'
    end

    it 'will display the something went wrong page when the session id does not match the cookie value' do
      set_session_cookies!
      set_session!(transaction_simple_id: 'test-rp', start_time: start_time_in_millis, verify_session_id: 'a mismatched value')
      visit '/start'
      expect(page).to have_content t('errors.something_went_wrong.heading')
      expect(page).to have_http_status :bad_request
      expect(page).to have_link 'feedback', href: '/feedback-landing?feedback-source=ERROR_PAGE'
    end

    it 'will display the timeout expiration error when the session start cookie is old' do
      session_id_cookie = create_cookie_hash[CookieNames::SESSION_ID_COOKIE_NAME]
      allow(Rails.logger).to receive(:info)
      expect(Rails.logger).to receive(:info).with("session \"#{session_id_cookie}\" has expired 30 minutes ago").at_least(:once)
      set_session_and_session_cookies!
      expired_start_time = 2.hours.ago.to_i * 1000
      page.set_rack_session(start_time: expired_start_time)
      visit '/start'
      expect(page.body).to include t('errors.session_timeout.return_to_service_html')
      expect(page).to have_http_status :forbidden
      expect(page).to have_link 'feedback', href: '/feedback-landing?feedback-source=EXPIRED_ERROR_PAGE'
    end
  end

  it 'will not allow robots to index' do
    set_session_and_session_cookies!
    visit '/start'
    expect(page).to have_css('meta[name="robots"][content="noindex"]', visible: false)
  end
end
