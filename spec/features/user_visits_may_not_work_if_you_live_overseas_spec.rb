require 'feature_helper'

RSpec.describe 'When the user visits the may-not-work-if-you-live-overseas page' do
  before(:each) do
    set_session_cookies!
  end

  context 'with javascript enabled', js: true do
    it 'contains the choose certified company link with selected evidence params' do
      page.set_rack_session('transaction_simple_id' => 'test-rp')
      visit '/may-not-work-if-you-live-overseas'

      expect(page).to have_link "I’d like to try to verify my identity online", href: "/choose-a-certified-company"
    end
  end

  it 'includes the appropriate feedback source' do
    page.set_rack_session('transaction_simple_id' => 'test-rp')
    visit '/may-not-work-if-you-live-overseas'

    expect_feedback_source_to_be(page, 'MAY_NOT_WORK_IF_YOU_LIVE_OVERSEAS_PAGE')
  end

  it 'includes other ways text' do
    page.set_rack_session('transaction_simple_id' => 'test-rp')
    visit '/may-not-work-if-you-live-overseas'

    expect(page).to have_content('If you can’t verify your identity using GOV.UK Verify, you can register for an identity profile here')
    expect(page).to have_content('register for an identity profile')
    expect(page).to have_link 'here', href: 'http://www.example.com'
  end

  context 'session does not contain transaction id' do
    before(:each) do
      stub_federation
    end

    it 'includes other ways text' do
      visit '/may-not-work-if-you-live-overseas'

      expect(page).to have_content('If you can’t verify your identity using GOV.UK Verify, you can register for an identity profile here')
      expect(page).to have_content('register for an identity profile')
      expect(page).to have_link 'here', href: 'http://www.example.com'
    end
  end
end
