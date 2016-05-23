require 'feature_helper'
require 'api_test_helper'

RSpec.describe 'When the user visits the response processing page' do
  before(:each) do
    set_session_cookies!
    page.set_rack_session(transaction_simple_id: 'test-rp')
  end

  it 'should show the user the rp name and a spinner' do
    stub_matching_outcome
    visit '/response-processing'
    expect(page).to have_content I18n.t('hub.response_processing.heading', rp_name: 'Test RP')
    expect(page).to have_css('img.loading')
  end

  it 'redirects to start page when response is GOTO_HUB_LANDING_PAGE' do
    stub_matching_outcome(MatchingOutcomeResponse::GOTO_HUB_LANDING_PAGE)
    visit '/response-processing'
    expect(page).to have_current_path('/start')
  end
end
