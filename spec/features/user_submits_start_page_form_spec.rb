require 'feature_helper'
require 'models/cookie_names'

RSpec.describe 'when user submits start page form' do
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

  it 'will display about page when user chooses yes (registration)' do
    set_session_cookies
    visit '/start'
    choose('yes')
    click_button('next-button')
    expect(current_path).to eq('/about')
  end

  it 'will display sign in with IDP page when user chooses no (sign in)' do
    set_session_cookies
    visit '/start'
    choose('no')
    click_button('next-button')
    expect(current_path).to eq('/sign-in')
  end

  it 'will prompt for an answer if no answer is given' do
    set_session_cookies
    visit '/start'
    click_button('next-button')
    expect(page).to have_content "Please answer the question"
  end
end
