require 'feature_helper'
require 'models/cookie_names'

RSpec.describe 'When the user visits the about choosing a company page' do
  before(:each) do
    set_session_cookies!
  end

  it 'will include the appropriate feedback source' do
    visit '/about-choosing-a-company'

    expect_feedback_source_to_be(page, 'ABOUT_CHOOSING_A_COMPANY_PAGE')
  end

  it 'will display content in Welsh' do
    visit '/am-ddewis-a-gwmni'

    expect(page).to have_content 'Dod o hyd i\'r cwmni hawl i wirio chi'
  end

  it 'will take user to select documents page when user clicks "Continue"' do
    visit '/about-choosing-a-company'

    click_link 'Continue'
    expect(page).to have_current_path('/select-documents')
  end
end
