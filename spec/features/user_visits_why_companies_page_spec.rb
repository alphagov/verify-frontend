require 'feature_helper'

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
    visit '/why-companies-cy'
    expect(page).to have_title 'Why there’s a choice of companies - GOV.UK Verify - GOV.UK'
    expect(page).to have_css 'html[lang=cy]'
  end

  it 'includes links to choose-a-certified-company page with the selected evidence', js: true do
    visit '/why-companies?selected-evidence=passport&selected-evidence=driving_licence&selected-evidence=non_uk_id_document'
    expect(page).to have_title('Why there’s a choice of companies - GOV.UK Verify - GOV.UK')
    expect(page).to have_link 'Back', href: '/choose-a-certified-company?selected-evidence=passport&selected-evidence=driving_licence&selected-evidence=non_uk_id_document'
    expect(page).to have_link 'Choose a company', href: '/choose-a-certified-company?selected-evidence=passport&selected-evidence=driving_licence&selected-evidence=non_uk_id_document'
  end
end
