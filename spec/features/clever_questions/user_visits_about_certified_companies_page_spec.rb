require 'feature_helper'
require 'api_test_helper'
require 'cookie_names'

RSpec.describe 'When the user visits the about certified companies page' do
  let(:simple_id) { 'stub-idp-one' }

  before(:each) do
    set_session_and_ab_session_cookies!('clever_questions' => 'clever_questions_variant')
    stub_transactions_list
    stub_api_idp_list_for_loa
  end

  it 'includes the appropriate feedback source' do
    visit '/about-certified-companies'

    expect_feedback_source_to_be(page, 'ABOUT_CERTIFIED_COMPANIES_PAGE', '/about-certified-companies')
  end

  it 'displays content in Welsh' do
    visit '/am-gwmniau-ardystiedig'

    expect(page).to have_content 'Defnyddiwch'
  end

  it 'displays IdPs that are enabled' do
    visit '/about-certified-companies'

    expect(page).to have_css("img[src*='/#{simple_id}']")
  end

  it 'will go to about choosing a company page when Continue is clicked if user on LOA2 journey' do
    visit '/about-certified-companies'
    click_link('Continue')

    expect(page).to have_current_path('/about-choosing-a-company')
  end
end
