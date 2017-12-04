require 'feature_helper'
require 'api_test_helper'
require 'cookie_names'

RSpec.describe 'When the user visits the about identity providers page' do
  let(:simple_id) { 'stub-idp-one' }

  before(:each) do
    set_session_and_ab_session_cookies!('clever_questions' => 'clever_questions_variant')
    stub_transactions_list
    stub_api_idp_list
  end

  it 'includes the appropriate feedback source' do
    visit '/about-identity-providers'

    expect_feedback_source_to_be(page, 'ABOUT_IDENTITY_PROVIDERS_PAGE', '/about-identity-providers')
  end

  it 'displays content in Welsh' do
    visit '/about-identity-providers-cy'

    expect(page).to have_content 'Defnyddiwch'
  end

  it 'displays IdPs that are enabled' do
    visit '/about-identity-providers'

    expect(page).to have_css("img[src*='/#{simple_id}']")
  end

  it 'will go to about choosing a identity provider page when Continue is clicked if user on LOA2 journey' do
    visit '/about-identity-providers'
    click_link('Continue')

    expect(page).to have_current_path('/about-choosing-an-identity-provider')
  end
end
