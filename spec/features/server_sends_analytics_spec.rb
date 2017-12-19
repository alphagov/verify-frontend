require 'feature_helper'
require 'piwik_test_helper'
require 'api_test_helper'

RSpec.describe 'When a page with a virtual page view is visited' do
  it 'sends a virtual page view to analytics' do
    page.set_rack_session(transaction_simple_id: 'test-rp')
    set_session_and_session_cookies!
    stub_api_idp_list_for_loa
    #TODO: temporarily setting LOA1, because we're not reporting this when AB test on LOA2 is running TT-1606
    set_loa_in_session('LEVEL_1')

    Capybara.current_session.driver.header('User-Agent', 'my user agent')
    Capybara.current_session.driver.header('Accept-Language', 'en-US,en;q=0.5')
    Capybara.current_session.driver.header('X-Forwarded-For', '1.1.1.1')

    visit '/start'

    piwik_request = {
        'rec' => '1',
        'apiv' => '1',
        'idsite' => INTERNAL_PIWIK.site_id.to_s,
        'cookie' => 'false',
        'action_name' => 'The user has reached the start page'
    }
    piwik_headers = {
        'X-Forwarded-For' => '1.1.1.1',
        'Connection' => 'Keep-Alive',
        'Host' => 'localhost:4242',
        'User-Agent' => 'my user agent',
        'Accept-Language' => 'en-US,en;q=0.5',
    }
    #TODO: temporarily setting LOA1, because we're not reporting this when AB test on LOA2 is running TT-1606
    stubbed_piwik_request = stub_piwik_request(piwik_request, piwik_headers, 'LEVEL_1')
    expect(stubbed_piwik_request).to have_been_made.at_least_once
  end
end
