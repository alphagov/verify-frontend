require 'feature_helper'
require 'api_test_helper'
require 'cookie_names'

RSpec.describe 'When the user visits the about identity accounts page' do
  before(:each) do
    set_session_and_session_cookies!
    stub_transactions_list
  end

  it 'includes the appropriate feedback source' do
    visit '/about-identity-accounts'

    expect_feedback_source_to_be(page, 'ABOUT_IDENTITY_ACCOUNTS_PAGE', '/about-identity-accounts')
  end

  it 'displays content in Welsh' do
    visit '/am-gyfrifon-hunaniaeth'

    expect(page).to have_content 'Darganfyddwch fwy am gwcis'
  end

  it 'will show "Where you can use your identity account" section listing public transactions' do
    visit '/about-identity-accounts'

    expect(page).to have_content 'Where you can use your identity account'
    expect(page).to have_content 'GOV.UK Verify is new, and government services are joining all the time. The current services  using Verify are:'
    expect(page).to have_content 'register for an identity profile'
    expect(page).to have_content 'Register for an identity profile (forceauthn & no cycle3)'
  end

  it 'will go to about choosing a company page when start now is clicked if user on LOA2 journey' do
    visit '/about-identity-accounts'
    click_link('Start now')

    expect(page).to have_current_path('/about-choosing-a-company')
  end

  it 'will go to choose a certified company page when start now is clicked if user on LOA1 journey' do
    page.set_rack_session(requested_loa: 'LEVEL_1')
    visit '/about-identity-accounts'
    click_link('Start now')

    expect(page).to have_current_path('/choose-a-certified-company')
  end
end
