require 'feature_helper'
require 'api_test_helper'

RSpec.describe 'When the user visits the will-not-work-without-uk-address page' do
  before(:each) do
    set_session_and_session_cookies!
    page.set_rack_session(transaction_simple_id: 'test-rp')
  end

  it 'includes other ways text' do
    visit '/will-not-work-without-uk-address'

    expect(page).to have_content('If you can’t verify your identity using GOV.UK Verify, you can register for an identity profile here')
    expect(page).to have_content('register for an identity profile')
    expect(page).to have_link 'here', href: 'http://www.example.com'
  end

  it 'includes the appropriate feedback source' do
    visit '/will-not-work-without-uk-address'

    expect_feedback_source_to_be(page, 'WILL_NOT_WORK_WITHOUT_UK_ADDRESS_PAGE')
  end
end
