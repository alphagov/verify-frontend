require 'feature_helper'

RSpec.describe 'When the user visits the privacy notice page' do
  it 'displays the page in English' do
    visit '/privacy-notice'
    expect(page).to have_title 'Privacy notice - GOV.UK Verify - GOV.UK'
    expect(page).to have_link 'Summary', href: '#summary'
    expect(page).to have_content 'GOV.UK Verify is provided by the Government Digital Service (GDS). We use your personal data to help you to transact securely with government services.'
    expect(page).to have_link 'Privacy policies of certified companies and government departments', href: '#privacy-policies-of-certified-companies-and-government-departments'
    expect(page).to have_content 'The certified companies have their own privacy policies that apply to their handling of your personal data as part of the identity verification process. Likewise, the government services have their own privacy policies that apply to their handling of your personal data when you use their services.'
  end

  it 'displays the page in Welsh' do
    visit '/hysbysiad-preifatrwydd'
    expect(page).to have_content("Mae GOV.UK Verify wrthi’n cael ei gyfieithu i’r Gymraeg.")
  end

  it 'includes the appropriate feedback source' do
    visit '/privacy-notice'
    expect_feedback_source_to_be(page, 'PRIVACY_NOTICE_PAGE')
  end
end
