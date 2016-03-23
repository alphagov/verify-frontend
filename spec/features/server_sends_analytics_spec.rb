require 'feature_helper'

RSpec.describe 'When the user visits the start page' do
  context 'when JS is enabled', js: true do
    it 'sends a virtual page view to analytics' do
      body = { 'idps' => [{ 'simpleId' => 'stub-idp-one', 'entityId' => 'http://idpcorp.com' }], 'transactionEntityId' => 'some-id' }
      stub_request(:get, api_uri('session/federation')).to_return(body: body.to_json)
      stub_request(:get, INTERNAL_PIWIK.url).with(query: hash_including({}))
      set_session_cookies!
      visit '/about'

      expect(page).to have_content 'GOV.UK Verify is a scheme to fight the growing problem of online identity theft'
      piwik_request = {
          'rec' => '1',
          'apiv' => '1',
          'idsite' => INTERNAL_PIWIK.site_id.to_s,
          'cookie' => 'false',
      }
      piwik_headers = {
          'X-Forwarded-For' => '<PRINCIPAL IP ADDRESS COULD NOT BE DETERMINED>',
          'Connection' => 'close',
          'Host' => 'localhost:4242',
          'User-Agent' => 'http.rb/1.0.3',
          'Accept-Language'  =>  'en-US,en;q=0.5',
      }
      expect(a_request(:get, INTERNAL_PIWIK.url).with(headers: piwik_headers, query: hash_including(piwik_request))).to have_been_made.once
    end
  end
end
