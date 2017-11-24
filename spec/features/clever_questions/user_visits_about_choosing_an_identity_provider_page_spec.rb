require 'feature_helper'
require 'api_test_helper'
require 'cookie_names'

RSpec.describe 'When the user visits the about choosing an identity provider page' do
  before(:each) do
    set_session_and_ab_session_cookies!('clever_questions' => 'clever_questions_variant')
    stub_transactions_list
    stub_api_idp_list
  end

  it 'includes the appropriate feedback source' do
    visit '/about-choosing-an-identity-provider'

    expect_feedback_source_to_be(page, 'ABOUT_CHOOSING_AN_IDENTITY_PROVIDER_PAGE', '/about-choosing-an-identity-provider')
  end

  it 'displays content in Welsh' do
    visit '/about-choosing-an-identity-provider-cy'

    expect(page).to have_content 'Defnyddiwch'
  end

  it 'will show "What other government services use GOV.UK Verify" section listing public transactions' do
    visit '/about-choosing-an-identity-provider'

    expect(page).to have_content 'What other government services use GOV.UK Verify'
    expect(page).to have_content 'GOV.UK Verify is new, and government services are joining all the time.'
    expect(page).to have_content 'register for an identity profile'
    expect(page).to have_content 'Register for an identity profile (forceauthn & no cycle3)'
  end

  it 'will go to select documents page when Continue is clicked if user on LOA2 journey' do
    visit '/about-choosing-an-identity-provider'
    click_link('Continue')

    expect(page).to have_current_path('/select-documents')
  end
end
