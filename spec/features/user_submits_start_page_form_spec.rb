require 'feature_helper'
require 'cookie_names'
require 'api_test_helper'

RSpec.describe 'when user submits start page form' do
  before(:each) { set_session_and_session_cookies! }

  it 'will display about page when user chooses yes (registration)' do
    stub_request(:get, INTERNAL_PIWIK.url)
    visit '/start'
    choose('start_form_selection_true')
    click_button('next-button')
    expect(current_path).to eq('/about')
  end

  it 'will display sign in with IDP page when user chooses sign in' do
    visit '/start'
    choose('start_form_selection_false')
    click_button('next-button')

    expect(current_path).to eq('/sign-in')
    expect(page).to have_content 'Who do you have an identity account with?'
    expect(page).to have_content 'IDCorp'
    expect(page).to have_css('img[src="/stub-logos/stub-idp-one.png"]')
    expect(page).to have_link 'Back', href: '/start'
    expect_feedback_source_to_be(page, 'SIGN_IN_PAGE')
    expect(page).to have_link 'start now', href: '/about'
    expect(page).to have_link "I can’t remember which company verified me", href: '/forgot-company'
  end

  it 'will report user choice to analytics when user chooses no (sign in)' do
    stub_request(:get, INTERNAL_PIWIK.url).with(query: hash_including({}))
    visit '/start'
    choose('start_form_selection_false')
    click_button('next-button')

    piwik_request = {
        'rec' => '1',
        'apiv' => '1',
        '_cvar' => '{"1":["RP","analytics description for test-rp"]}'
    }
    expect(a_request(:get, INTERNAL_PIWIK.url).with(query: hash_including(piwik_request))).to have_been_made.once
  end

  it 'will prompt for an answer if no answer is given' do
    visit '/start'
    click_button('next-button')
    expect(page).to have_content "Please select an option"
  end
end
