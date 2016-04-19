require 'feature_helper'

RSpec.describe 'When the user visits the may-not-work-if-you-live-overseas page' do
  before(:each) do
    set_session_cookies!
    stub_federation
  end

  context 'with javascript enabled', js: true do
    it 'contains the choose certified company link with selected evidence params' do
      visit '/may-not-work-if-you-live-overseas?selected-evidence=smart_phone&selected-evidence=mobile_phone&selected-evidence=driving_licence&selected-evidence=passport'

      expect(page).to have_link "I’d like to try to verify my identity online", href: "/choose-a-certified-company?selected-evidence=smart_phone&selected-evidence=mobile_phone&selected-evidence=driving_licence&selected-evidence=passport"
    end
  end

  it 'includes the appropriate feedback source' do
    visit '/may-not-work-if-you-live-overseas'

    expect_feedback_source_to_be(page, 'MAY_NOT_WORK_IF_YOU_LIVE_OVERSEAS_PAGE')
  end

  it 'includes other ways text' do
    visit '/may-not-work-if-you-live-overseas'

    expect(page).to have_content("If you can't verify your identity using GOV.UK Verify, you can register for an identity profile here")
    expect(page).to have_content('register for an identity profile')
    expect(page).to have_link 'here', href: 'http://www.example.com'
  end
end
