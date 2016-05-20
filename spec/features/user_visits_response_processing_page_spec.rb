require 'feature_helper'

RSpec.describe 'When the user visits the response processing page' do
  it 'should show the user the rp name and a spinner' do
    set_session_cookies!
    page.set_rack_session(transaction_simple_id: 'test-rp')
    visit '/response-processing'
    expect(page).to have_content I18n.t('hub.response_processing.heading', rp_name: 'Test RP')
    expect(page).to have_css('img.loading')
  end
end
