require 'feature_helper'
require 'api_test_helper'

RSpec.describe 'When the user visits the Verify will not work for you page' do
  before(:each) do
    set_session_and_session_cookies!
    page.set_rack_session(transaction_simple_id: 'test-rp')
  end

  it 'displays the page in Welsh' do
    visit '/ni-fydd-verify-yn-gweithio-i-chi'
    expect(page).to have_css 'html[lang=cy]'
  end

  it 'displays the page in English' do
    visit '/verify-will-not-work-for-you'
    expect(page).to have_css 'html[lang=en]'
  end

  it 'includes the appropriate feedback source' do
    visit '/verify-will-not-work-for-you'

    expect_feedback_source_to_be(page, 'VERIFY_WILL_NOT_WORK_FOR_YOU', '/verify-will-not-work-for-you')
  end

  it 'includes other ways text' do
    visit '/verify-will-not-work-for-you'

    expect(page).to have_content('If you can’t verify your identity using GOV.UK Verify, you can test GOV.UK Verify user journeys here')
    expect(page).to have_content('test GOV.UK Verify user journeys')
    expect(page).to have_link 'here', href: 'http://www.example.com'
  end
end
