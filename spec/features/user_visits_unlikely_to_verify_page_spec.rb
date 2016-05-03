require 'feature_helper'

RSpec.describe 'When the user visits the unlikely-to-verify page' do
  before(:each) do
    set_session_cookies!
    stub_federation
  end

  it 'displays the page in Welsh' do
    visit '/unlikely-to-verify-cy'
    expect(page).to have_content('You need a valid passport, photocard driving licence or national identity card (ID card) to get your identity verified.')
    expect(page).to have_css 'html[lang=cy]'
  end

  it 'displays the page in English' do
    visit '/unlikely-to-verify'
    expect(page).to have_content('You need a valid passport, photocard driving licence or national identity card (ID card) to get your identity verified.')
    expect(page).to have_css 'html[lang=en]'
  end

  it 'includes other ways text' do
    visit '/unlikely-to-verify'

    expect(page).to have_content('If you can’t verify your identity using GOV.UK Verify, you can register for an identity profile here')
    expect(page).to have_content('register for an identity profile')
    expect(page).to have_link 'here', href: 'http://www.example.com'
  end

  it 'includes the appropriate feedback source' do
    visit '/unlikely-to-verify'

    expect_feedback_source_to_be(page, 'UNLIKELY_TO_VERIFY_PAGE')
  end
end
