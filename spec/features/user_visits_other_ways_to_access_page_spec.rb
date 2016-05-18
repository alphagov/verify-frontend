require 'feature_helper'

RSpec.describe 'When the user visits the other ways to access page' do
  before(:each) do
    set_session_cookies!
    page.set_rack_session(transaction_simple_id: 'test-rp')
  end

  it 'includes expected content' do
    visit '/other-ways-to-access-service'

    expect(page).to have_title 'Other ways to access the service - GOV.UK Verify - GOV.UK'
    expect(page).to have_content 'Other ways to register for an identity profile'
    expect(page).to have_content 'If you can’t verify your identity using GOV.UK Verify, you can register for an identity profile'
    expect(page).to have_link 'here', href: 'http://www.example.com'
    expect_feedback_source_to_be(page, 'OTHER_WAYS_PAGE')
  end
end
