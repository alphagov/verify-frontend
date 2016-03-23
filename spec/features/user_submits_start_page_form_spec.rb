require 'feature_helper'
require 'models/cookie_names'

def given_api_returns_federation_info
  body = { 'idps' => [{ 'simpleId' => 'stub-idp-one', 'entityId' => 'http://idcorp.com' }], 'transactionEntityId' => 'some-id' }
  stub_request(:get, api_uri('session/federation')).to_return(body: body.to_json)
end

RSpec.describe 'when user submits start page form' do
  it 'will display about page when user chooses yes (registration)' do
    given_api_returns_federation_info
    stub_request(:get, INTERNAL_PIWIK.url)
    set_session_cookies!
    visit '/start'
    choose('yes')
    click_button('next-button')
    expect(current_path).to eq('/about')
  end

  it 'will display sign in with IDP page when user chooses sign in' do
    given_api_returns_federation_info
    set_session_cookies!
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
    expect(page).to have_link "I can’t remember which company verified me", href: '/forgot_company'
  end

  it 'will report user choice to analytics when user chooses no (sign in)' do
    set_session_cookies!
    given_api_returns_federation_info
    stub_request(:get, INTERNAL_PIWIK.url).with(query: hash_including({}))
    visit '/start'
    choose('no')
    click_button('next-button')

    piwik_request = {
        'rec' => '1',
        'apiv' => '1',
        '_cvar' => '{"1":["RP","some-id"]}'
    }
    expect(a_request(:get, INTERNAL_PIWIK.url).with(query: hash_including(piwik_request))).to have_been_made.once
  end

  it 'will prompt for an answer if no answer is given' do
    set_session_cookies!
    visit '/start'
    click_button('next-button')
    expect(page).to have_content "Please select an option"
  end
end
