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
  let(:session_start_time_cookie) { "my-session-start-time-cookie" }
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
    expect(a_request(:get, session_info_route)).to_not have_been_made
  end

  it 'will display the generic error when start time cookie is missing'
  it 'will display the generic error when the secure cookie is missing'
  it 'will display the generic error when the session id cookie is missing'

  it 'will display the timeout expiration error when the session start cookie is old' do
    pending
    stub_request(:get, session_info_route).to_return(status: 401, body: {'reason' => 'start time cookie expired'}.to_json)
    set_session_cookies
    visit "/start"
    expect(a_request(:get, session_info_route).with(headers: {"Cookie" => cookie_values})).to have_been_made.once
    expect(page).to have_content "Please go back to your service to start again."
  end
  it 'will display the generic error when cookie validating fails'
end
