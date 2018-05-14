require 'feature_helper'

RSpec.describe 'When the user visits the privacy notice page' do
  it 'displays the page in English' do
    visit '/privacy-notice'
    expect(page).to have_title t('hub.privacy_notice.title')
    expect(page).to have_content 'To verify your identity, we will pass the personal data that you give to your chosen certified company to the government service that you want to access.'
    expect(page).to have_link 'DPO@cabinetoffice.gov.uk', href: 'mailto:DPO@cabinetoffice.gov.uk'
    expect(page).to have_content 'The data controller for your personal data is the Cabinet Office – a data controller determines how and why personal data is processed.'
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
