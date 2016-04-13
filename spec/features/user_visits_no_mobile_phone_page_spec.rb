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

    expect(page).to have_content('Other ways text')
    expect(page).to have_content('Other ways description')
    expect(page).to have_css('a[href=\'http://www.example.com\']', 'with a link')
  end
end
