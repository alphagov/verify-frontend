require 'feature_helper'
require 'api_test_helper'
require 'cookie_names'

RSpec.describe 'When the user visits the start page' do
  it 'will display the start page in English' do
    set_session_and_session_cookies!
    visit '/start'
    expect(page).to have_content 'Sign in with GOV.UK Verify'
    expect(page).to have_css 'html[lang=en]'
    expect_feedback_source_to_be(page, 'START_PAGE', '/start')
  end

  it 'will display the start page in Welsh' do
    set_session_and_session_cookies!
    visit '/dechrau'
    expect(page).to have_content 'Mewngofnodi gyda GOV.UK Verify'
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

  it 'will set ab_test cookie' do
    set_session_and_session_cookies!
    visit '/start'
    header = cookie_header(CookieNames::AB_TEST)
    expect(header).to match(/expires=#{2.weeks.from_now.strftime(RACK_COOKIE_DATE_FORMAT)}/)
  end

  it 'will not set ab_test cookie if already set' do
    set_session_and_session_cookies!
    cookie_hash = create_cookie_hash.merge!(ab_test: CGI.escape({ 'about_companies' => 'about_companies_with_logo',
                                                                  'split_questions_v2' => 'split_questions_v2_control',
                                                                  'select_documents_v2' => 'select_documents_v2_control',
                                                                  'proof_of_address' => 'select_proof_of_address_control'
                                                                }.to_json))
    set_cookies!(cookie_hash)
    page.set_rack_session(transaction_simple_id: 'test-rp')
    visit '/start'
    expect(page.response_headers['Set-Cookie']).not_to include("ab_test=")
  end

  it 'will include both experiments in the ab_test cookie if only one experiment is currently in the ab_test cookie' do
    set_session_and_session_cookies!
    cookie_hash = create_cookie_hash.merge!(ab_test: CGI.escape({ 'about_companies' => 'about_companies_no_logo' }.to_json))
    set_cookies!(cookie_hash)
    page.set_rack_session(transaction_simple_id: 'test-rp')
    visit '/start'
    header = cookie_header(CookieNames::AB_TEST)
    expect(header).to match(/about_companies/)
    expect(header).to match(/about_companies_no_logo/)
    expect(header).to match(/expires=#{2.weeks.from_now.strftime(RACK_COOKIE_DATE_FORMAT)}/)
  end

  it 'will not set ab_test cookie if RP is in AB test blacklist' do
    set_session_and_session_cookies!
    page.set_rack_session(transaction_simple_id: 'test-rp-no-ab-test')
    visit '/start'
    expect(page.response_headers['Set-Cookie']).to_not include("ab_test=")
  end

  it 'will not allow robots to index' do
    set_session_and_session_cookies!
    visit '/start'
    expect(page).to have_css('meta[name="robots"][content="noindex"]', visible: false)
  end
end
