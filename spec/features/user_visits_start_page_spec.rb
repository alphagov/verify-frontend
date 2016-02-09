require 'feature_helper'

RSpec.describe 'When the user visits the start page' do
  def set_cookies(hash)
    hash.each do |key, value|
      Capybara.current_session.driver.browser.set_cookie "#{key}=#{value}"
    end
  end

  def set_session_cookies
    set_cookies(cookie_hash)
  end

  let(:session_info_route) { 'http://api/api/session' }
  let(:secure_cookie) { "my-secure-cookie" }
  let(:session_id_cookie) { "my-session-id-cookie" }
  let(:session_start_time_cookie) { DateTime.now.to_i }
  let(:cookie_hash) {
    {
      "x-govuk-secure-cookie" => secure_cookie,
      "session_start_time" => session_start_time_cookie,
      "x_govuk_session_cookie" => session_id_cookie,
    }
  }
  let(:cookie_values) {
    "some-cookie-values"
  }

  it 'will display the start page in English' do
    set_session_cookies
    visit '/start'
    expect(page).to have_content 'Sign in with GOV.UK Verify'
    expect(page).to have_css 'html[lang=en]'
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
  end

  it 'will display the generic error when start time cookie is missing' do
    allow(Rails.logger).to receive(:info)
    expect(Rails.logger).to receive(:info).with("The following cookies are missing: [session_start_time]").at_least(:once)
    set_cookies(cookie_hash.except("session_start_time"))
    visit '/start'
    expect(page).to have_content "Sorry, something went wrong"
  end

  it 'will display the generic error when the secure cookie is missing' do
    allow(Rails.logger).to receive(:info)
    expect(Rails.logger).to receive(:info).with("The following cookies are missing: [x-govuk-secure-cookie]").at_least(:once)
    set_cookies(cookie_hash.except("x-govuk-secure-cookie"))
    visit '/start'
    expect(page).to have_content "Sorry, something went wrong"
  end

  it 'will display the generic error when the session id cookie is missing' do
    allow(Rails.logger).to receive(:info)
    expect(Rails.logger).to receive(:info).with("The following cookies are missing: [x_govuk_session_cookie]").at_least(:once)
    set_cookies(cookie_hash.except("x_govuk_session_cookie"))
    visit '/start'
    expect(page).to have_content "Sorry, something went wrong"
  end

  it 'will display the timeout expiration error when the session start cookie is old' do
    allow(Rails.logger).to receive(:info)
    expect(Rails.logger).to receive(:info).with("session_start_time cookie for session \"#{session_id_cookie}\" has expired").at_least(:once)
    set_session_cookies
    expired_start_time = 2.hours.ago.to_i
    set_cookies({"session_start_time" => expired_start_time})
    visit "/start"
    expect(page).to have_content "Your session has timed out"
    expect(page).to have_content "Find the service you were using to start again"
  end
end
