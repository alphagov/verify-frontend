require 'feature_helper'
require 'piwik_test_helper'

RSpec.describe 'When a page with a virtual page view is visited' do
  it 'sends a virtual page view to analytics' do
    page.set_rack_session(transaction_simple_id: 'test-rp')
    set_session_and_session_cookies!
    Capybara.current_session.driver.header('User-Agent', 'my user agent')
    Capybara.current_session.driver.header('Accept-Language', 'en-US,en;q=0.5')
    Capybara.current_session.driver.header('X-Forwarded-For', '1.1.1.1')

    visit '/sign-in'

    piwik_request = {
        'rec' => '1',
        'apiv' => '1',
        'idsite' => INTERNAL_PIWIK.site_id.to_s,
        'cookie' => 'false',
    }
    piwik_headers = {
        'X-Forwarded-For' => '1.1.1.1',
        'Connection' => 'Keep-Alive',
        'Host' => 'localhost:4242',
        'User-Agent' => 'my user agent',
        'Accept-Language' => 'en-US,en;q=0.5',
    }
    stubbed_piwik_request = stub_piwik_request(piwik_request, piwik_headers)
    expect(stubbed_piwik_request).to have_been_made.at_least_once
  end
end
