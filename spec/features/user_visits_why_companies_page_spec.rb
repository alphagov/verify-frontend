require 'feature_helper'
require 'api_test_helper'

RSpec.describe 'When the user visits the why companies page' do
  before(:each) do
    set_session_cookies!
  end

  it 'includes the appropriate feedback source' do
    stub_federation
    visit '/why-companies'

    expect_feedback_source_to_be(page, 'WHY_COMPANIES_PAGE')
  end

  it 'displays the page in Welsh' do
    visit '/pam-cwmniau'
    expect(page).to have_title 'Pam fod dewis o gwmnïau - GOV.UK Verify - GOV.UK'
    expect(page).to have_css 'html[lang=cy]'
  end

  it 'includes links to choose-a-certified-company page with the selected evidence', js: true do
    visit '/why-companies'
    expect(page).to have_title('Why there’s a choice of companies - GOV.UK Verify - GOV.UK')
    expect(page).to have_link 'Back', href: '/choose-a-certified-company'
    expect(page).to have_link 'Choose a company', href: '/choose-a-certified-company'
  end
end
