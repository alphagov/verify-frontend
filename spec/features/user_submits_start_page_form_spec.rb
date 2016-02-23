require 'feature_helper'
require 'models/cookie_names'

RSpec.describe 'when user submits start page form' do
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
    cookies_regex = "#{CookieNames::SESSION_STARTED_TIME_COOKIE_NAME}=#{session_start_time_cookie}; " +
      "#{CookieNames::SECURE_COOKIE_NAME}=#{secure_cookie}; " +
      "#{CookieNames::SESSION_ID_COOKIE_NAME}=#{session_id_cookie}"
    expected_headers = {'Cookie' => cookies_regex}

    body = [{'simpleId' => 'stub-idp-one', 'entityId' => 'http://idcorp.com'}]
    stub_request(:get, api_uri('session/idps')).with(headers: expected_headers).to_return(body: body.to_json)
    set_session_cookies
    visit '/start'
    choose('no')
    click_button('next-button')
    expect(current_path).to eq('/sign-in')
    expect(page).to have_content 'Who do you have an identity account with?'
    expect(page).to have_content 'IDCorp'
    expect(page).to have_css('img[src="/stub-logos/stub-idp-one.png"]')
  end

  it 'will prompt for an answer if no answer is given' do
    set_session_cookies
    visit '/start'
    click_button('next-button')
    expect(page).to have_content "Please select an option"
  end
end
