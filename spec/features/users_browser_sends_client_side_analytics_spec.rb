require 'feature_helper'
require 'models/cookie_names'
require 'pact/consumer/rspec'

Pact.service_consumer "browser" do
  has_pact_with "Piwik" do
    mock_service :piwik do
      port ENV.fetch('PIWIK_PORT').to_i
    end
  end
end

RSpec.describe 'When the user visits the start page', pact: true do
  it 'send a page view to analytics', js: true do
    piwik.given("whatever")
      .upon_receiving("a tracking request").
      with(method: :get, path: '/piwik.php', query: pact_query('Start - GOV.UK Verify - GOV.UK', '5')).
      will_respond_with(status: 200)

    set_session_cookies!
    visit '/start'
    expect(page).to have_content 'Sign in with GOV.UK Verify'
  end
end

def pact_query(action_name, site_id)
  {
      'action_name' => action_name,
      'idsite' => site_id,
      'rec' => Pact.like('1'),
      'r' => Pact.like('123456'),
      'h' => Pact.like('16'),
      'm' => Pact.like('8'),
      's' => Pact.like('24'),
      'url' => Pact.term(generate: 'http://127.0.0.1:49893/start', matcher: /https?:\/\/.*/),
      '_id' => Pact.like('e550edc82116a56c'),
      '_idts' => Pact.like('1458058078'),
      '_idvc' => Pact.like('1'),
      '_idn' => Pact.like('1'),
      '_refts' => Pact.like('1'),
      '_viewts' => Pact.like('1458058078'),
      'pdf' => Pact.like('1'),
      'qt' => Pact.like('1'),
      'realp' => Pact.like('1'),
      'wma' => Pact.like('1'),
      'dir' => Pact.like('1'),
      'fla' => Pact.like('1'),
      'java' => Pact.like('1'),
      'gears' => Pact.like('1'),
      'cookie' => Pact.like('1'),
      'ag' => Pact.like('1'),
      'res' => Pact.term(generate: '1920x1080', matcher: /.*/),
      'gt_ms' => Pact.term(generate: '1', matcher: /.*/),
  }
end
