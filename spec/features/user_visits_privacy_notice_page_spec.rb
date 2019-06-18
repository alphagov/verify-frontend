require 'feature_helper'

RSpec.describe 'When the user visits the privacy notice page' do
  it 'displays the page in English' do
    visit '/privacy-notice'
    expect(page).to have_title t('hub.privacy_notice.title')
    expect(page).to have_content 'We process information about you when you use GOV.UK Verify. This may include any of the following.'
    expect(page).to have_link 'DPO@cabinetoffice.gov.uk', href: 'mailto:DPO@cabinetoffice.gov.uk'
    expect(page).to have_content 'Cabinet Office is the data controller for the data processed by GOV.UK Verify.'
  end

  it 'displays the page in Welsh' do
    visit '/hysbysiad-preifatrwydd'
    expect(page).to have_title t('hub.privacy_notice.title', locale: :cy)
  end

  it 'includes the appropriate feedback source' do
    visit '/privacy-notice'
    expect_feedback_source_to_be(page, 'PRIVACY_NOTICE_PAGE', '/privacy-notice')
  end
end
