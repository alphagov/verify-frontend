require 'feature_helper'
require 'models/cookie_names'

RSpec.describe 'when user submits start page form' do
  it 'will display about page when user chooses yes (registration)' do
    set_session_cookies!
    visit '/start'
    choose('yes')
    click_button('next-button')
    expect(current_path).to eq('/about')
  end

  it 'will display sign in with IDP page when user chooses sign in' do
    cookies = set_session_cookies!
    cookie_names = [CookieNames::SESSION_STARTED_TIME_COOKIE_NAME, CookieNames::SECURE_COOKIE_NAME, CookieNames::SESSION_ID_COOKIE_NAME]
    expected_cookies_header = cookie_names.map { |name| "#{name}=#{cookies[name]}" }.join('; ')
    expected_headers = {'Cookie' => expected_cookies_header}
    body = [{'simpleId' => 'stub-idp-one', 'entityId' => 'http://idcorp.com'}]
    stub_request(:get, api_uri('session/idps')).with(headers: expected_headers).to_return(body: body.to_json)
    visit '/start'
    choose('no')
    click_button('next-button')
    expect(current_path).to eq('/sign-in')
    expect(page).to have_content 'Who do you have an identity account with?'
    expect(page).to have_content 'IDCorp'
    expect(page).to have_css('img[src="/stub-logos/stub-idp-one.png"]')
    expect(page).to have_link 'Back', href: '/start'
    expect_feedback_source_to_be(page, 'SIGN_IN_PAGE')
    expect(page).to have_link 'start now', href: '/about'
    expect(page).to have_link "I can't remember which company verified me", href: '/forgot_company'
  end

  it 'will prompt for an answer if no answer is given' do
    set_session_cookies!
    visit '/start'
    click_button('next-button')
    expect(page).to have_content "Please select an option"
  end
end
