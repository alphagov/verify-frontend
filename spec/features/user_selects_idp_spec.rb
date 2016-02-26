require 'feature_helper'

RSpec.describe 'user selects an IDP on the sign in page' do
  context 'with JS enabled' do
    it 'will redirect the user to the IDP' do
      body = [{'simpleId' => 'stub-idp-one', 'entityId' => 'http://idcorp.com'}]
      stub_request(:get, api_uri('session/idps')).with(headers: expected_headers).to_return(body: body.to_json)
      set_session_cookies
      visit '/sign-in'
      click_button('stub-idp-one')
    end
  end
  context 'with JS disabled' do
    it 'will display the interstitial page'
  end
end
