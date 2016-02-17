require 'feature_helper'
require 'models/cookie_names'

RSpec.describe 'When the user visits the start page' do
  let(:session_info_route) { 'http://api/api/session' }
  let(:secure_cookie) { "my-secure-cookie" }
  let(:session_id_cookie) { "my-session-id-cookie" }
  let(:session_start_time_cookie) { create_session_start_time_cookie }
  let(:cookie_hash) {
    {
        CookieNames::SECURE_COOKIE_NAME => secure_cookie,
        CookieNames::SESSION_STARTED_TIME_COOKIE_NAME => session_start_time_cookie,
        CookieNames::SESSION_ID_COOKIE_NAME => session_id_cookie,
    }
  }

  def set_cookies(hash)
    hash.each do |key, value|
      Capybara.current_session.driver.browser.set_cookie "#{key}=#{value}"
    end
  end

  def set_session_cookies
    set_cookies(cookie_hash)
  end

  it 'will display the start page in English' do
    set_session_cookies
    visit '/start'
    expect(page).to have_content 'Sign in with GOV.UK Verify'
    expect(page).to have_css 'html[lang=en]'
    expect(page).to have_link 'feedback', href: '/feedback?feedback-source=SIGN_IN_PAGE'
  end

  it 'will display the start page in Welsh' do
    set_session_cookies
    visit '/dechrau'
    expect(page).to have_content 'Mewngofnodi gyda GOV.UK Verify'
    expect(page).to have_css 'html[lang=cy]'
  end

  it 'will display the no cookies error when all cookies are missing' do
    allow(Rails.logger).to receive(:info)
    expect(Rails.logger).to receive(:info).with("No session cookies can be found").at_least(:once)
    visit "/start"
    expect(page).to have_content "If you can't access GOV.UK Verify from a service, enable your cookies."
    expect(page).to have_http_status :forbidden
    expect(page).to have_link 'feedback', href: '/feedback?feedback-source=COOKIE_NOT_FOUND_PAGE'
  end

  it 'will display the generic error when start time cookie is missing' do
    allow(Rails.logger).to receive(:info)
    expect(Rails.logger).to receive(:info).with("The following cookies are missing: [#{CookieNames::SESSION_STARTED_TIME_COOKIE_NAME}]").at_least(:once)
    set_cookies(cookie_hash.except(CookieNames::SESSION_STARTED_TIME_COOKIE_NAME))
    visit '/start'
    expect(page).to have_content "Sorry, something went wrong"
    expect(page).to have_http_status :internal_server_error
    expect(page).to have_link 'feedback', href: '/feedback?feedback-source=ERROR_PAGE'
  end

  it 'will display the generic error when the secure cookie is missing' do
    allow(Rails.logger).to receive(:info)
    expect(Rails.logger).to receive(:info).with("The following cookies are missing: [#{CookieNames::SECURE_COOKIE_NAME}]").at_least(:once)
    set_cookies(cookie_hash.except(CookieNames::SECURE_COOKIE_NAME))
    visit '/start'
    expect(page).to have_content "Sorry, something went wrong"
    expect(page).to have_http_status :internal_server_error
    expect(page).to have_link 'feedback', href: '/feedback?feedback-source=ERROR_PAGE'
  end

  it 'will display the generic error when the session id cookie is missing' do
    allow(Rails.logger).to receive(:info)
    expect(Rails.logger).to receive(:info).with("The following cookies are missing: [#{CookieNames::SESSION_ID_COOKIE_NAME}]").at_least(:once)
    set_cookies(cookie_hash.except(CookieNames::SESSION_ID_COOKIE_NAME))
    visit '/start'
    expect(page).to have_content "Sorry, something went wrong"
    expect(page).to have_http_status :internal_server_error
    expect(page).to have_link 'feedback', href: '/feedback?feedback-source=ERROR_PAGE'
  end

  it 'will display the timeout expiration error when the session start cookie is old' do
    allow(Rails.logger).to receive(:info)
    expect(Rails.logger).to receive(:info).with("#{CookieNames::SESSION_STARTED_TIME_COOKIE_NAME} cookie for session \"#{session_id_cookie}\" has expired").at_least(:once)
    set_session_cookies
    expired_start_time = 2.hours.ago.to_i
    set_cookies({CookieNames::SESSION_STARTED_TIME_COOKIE_NAME => expired_start_time})
    visit "/start"
    expect(page).to have_content "Your session has timed out"
    expect(page).to have_content "Find the service you were using to start again"
    expect(page).to have_http_status :bad_request
    expect(page).to have_link 'feedback', href: '/feedback?feedback-source=EXPIRED_ERROR_PAGE'
  end
end
