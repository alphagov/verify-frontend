require 'feature_helper'
require 'api_test_helper'
require 'cookie_names'

RSpec.describe 'When the user visits the start page with a variant cookie' do
  context 'on LOA2' do
    it 'will display the control start page for LOA2 in English' do
      set_session_and_ab_session_cookies!('loa1_shortened_journey_v3' => 'loa1_shortened_journey_v3_variant')
      visit '/start'
      expect(page).to have_content 'Sign in with GOV.UK Verify'
      expect(page).to have_css 'html[lang=en]'
      expect_feedback_source_to_be(page, 'START_PAGE', '/start')
    end
  end
  context 'on LOA1' do
    before(:each) do
      set_session_and_ab_session_cookies!('loa1_shortened_journey_v3' => 'loa1_shortened_journey_v3_variant')
      set_loa_in_session('LEVEL_1')
    end

    it 'will display the variant start page for LOA1 in English' do
      visit '/start'
      expect(page).to have_content 'Create an identity account'
      expect(page).to have_css 'html[lang=en]'
      expect_feedback_source_to_be(page, 'START_PAGE', '/start')
    end

    it 'will redirect to IDP picker when selecting Create an identity account' do
      stub_api_idp_list_for_loa(default_idps, 'LEVEL_1')
      visit '/start'
      expect(page).to have_content 'Create an identity account'
      click_link 'Create an identity account'
      expect(page).to have_current_path('/choose-a-certified-company')
      expect_feedback_source_to_be(page, 'CHOOSE_A_CERTIFIED_COMPANY_PAGE', '/choose-a-certified-company')
    end

    it 'on LOA1 will redirect to sign in page when selecting sign in' do
      stub_api_idp_list_for_sign_in(default_idps)
      visit '/start'
      expect(page).to have_content 'Create an identity account'
      click_link 'sign in'
      expect(page).to have_current_path('/sign-in')
      expect_feedback_source_to_be(page, 'SIGN_IN_PAGE', '/sign-in')
    end
  end

  context 'when there is an error' do
    before(:each) do
      stub_transactions_list
    end

    it 'will display the no cookies error when all cookies are missing' do
      allow(Rails.logger).to receive(:info)
      expect(Rails.logger).to receive(:info).with("No session cookies can be found").at_least(:once)
      visit '/start'
      expect(page).to have_content "If you can’t access GOV.UK Verify from a service, enable your cookies."
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
      expect(page).to have_content 'Sorry, something went wrong'
      expect(page).to have_http_status :internal_server_error
      expect(page).to have_link 'feedback', href: '/feedback?feedback-source=ERROR_PAGE'
    end

    it 'will display the generic error when the session cookie is missing' do
      cookie_hash = create_cookie_hash
      allow(Rails.logger).to receive(:info)
      expect(Rails.logger).to receive(:info).with("The following cookies are missing: [#{CookieNames::SESSION_COOKIE_NAME}]").at_least(:once)
      set_cookies!(cookie_hash.except(CookieNames::SESSION_COOKIE_NAME))
      visit '/start'
      expect(page).to have_content "Sorry, something went wrong"
      expect(page).to have_http_status :internal_server_error
      expect(page).to have_link 'feedback', href: '/feedback?feedback-source=ERROR_PAGE'
    end

    it 'will display the generic error when the session id cookie is missing' do
      cookie_hash = create_cookie_hash
      allow(Rails.logger).to receive(:info)
      expect(Rails.logger).to receive(:info).with("The following cookies are missing: [#{CookieNames::SESSION_ID_COOKIE_NAME}]").at_least(:once)
      set_cookies!(cookie_hash.except(CookieNames::SESSION_ID_COOKIE_NAME))
      visit '/start'
      expect(page).to have_content "Sorry, something went wrong"
      expect(page).to have_http_status :internal_server_error
      expect(page).to have_link 'feedback', href: '/feedback?feedback-source=ERROR_PAGE'
    end

    it 'will display the something went wrong page when the session id is missing' do
      set_session_cookies!
      set_session!(transaction_simple_id: 'test-rp', start_time: start_time_in_millis)
      visit '/start'
      expect(page).to have_content 'Sorry, something went wrong'
      expect(page).to have_http_status :internal_server_error
      expect(page).to have_link 'feedback', href: '/feedback?feedback-source=ERROR_PAGE'
    end

    it 'will display the something went wrong page when the session id does not match the cookie value' do
      set_session_cookies!
      set_session!(transaction_simple_id: 'test-rp', start_time: start_time_in_millis, verify_session_id: 'a mismatched value')
      visit '/start'
      expect(page).to have_content 'Sorry, something went wrong'
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
      expect(page).to have_content 'Find the service you were using to start again'
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
