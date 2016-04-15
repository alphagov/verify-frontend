require 'feature_helper'

RSpec.describe 'When the user visits the select phone page' do
  before(:each) do
    set_session_cookies!
    stub_federation
  end

  it 'includes the appropriate feedback source' do
    visit '/no-mobile-phone'

    expect_feedback_source_to_be(page, 'NO_MOBILE_PHONE')
  end

  it 'includes other ways text' do
    visit '/no-mobile-phone'

    expect(page).to have_content("If you can't verify your identity using GOV.UK Verify, you can register for an identity profile here")
    expect(page).to have_content('register for an identity profile')
    expect(page).to have_css('a[href=\'http://www.example.com\']', 'here')
  end
end
