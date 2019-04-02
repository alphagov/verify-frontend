require 'feature_helper'
require 'api_test_helper'

RSpec.describe 'When the user visits the may-not-work-if-you-live-overseas page' do
  before(:each) do
    set_session_and_session_cookies!
    page.set_rack_session(transaction_simple_id: 'test-rp')
  end

  it 'includes the appropriate feedback source and other ways text' do
    visit '/may-not-work-if-you-live-overseas'

    expect_feedback_source_to_be(page, 'MAY_NOT_WORK_IF_YOU_LIVE_OVERSEAS_PAGE', '/may-not-work-if-you-live-overseas')
    expect(page).to have_content('If you can’t verify your identity using GOV.UK Verify, you can test GOV.UK Verify user journeys here')
    expect(page).to have_content('test GOV.UK Verify user journeys')
    expect(page).to have_link 'here', href: 'http://www.example.com'
  end

  it 'redirects to select documents page if user clicks try to verify link' do
    visit may_not_work_if_you_live_overseas_path

    click_link 'I’d like to try to verify my identity using GOV.UK Verify'

    expect(page).to have_current_path(select_documents_path)
  end
end
