require 'feature_helper'
require 'api_test_helper'

RSpec.describe 'When the user visits the response processing page' do
  before(:each) do
    set_session_and_session_cookies!
    page.set_rack_session(transaction_simple_id: 'test-rp')
  end

  it 'does not show language links' do
    stub_matching_outcome
    visit '/response-processing'
    expect(page).to_not have_link 'Cymraeg'
  end

  it 'should show the user the rp name and a spinner' do
    stub_matching_outcome
    visit '/response-processing'
    expect(page).to have_content I18n.t('hub.response_processing.heading', rp_name: 'Test RP')
    expect(page).to have_css('img.loading')
    expect(page).to have_css 'meta[http-equiv=refresh]', visible: false
  end

  it 'displays the content in Welsh' do
    stub_matching_outcome
    visit '/prosesu-ymateb'
    expect(page).to have_css 'html[lang=cy]'
  end
end
