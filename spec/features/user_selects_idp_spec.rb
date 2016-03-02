require 'feature_helper'

RSpec.describe 'user selects an IDP on the sign in page' do
  context 'with JS enabled', js: true do
    it 'will redirect the user to the IDP' do
      body = [{'simpleId' => 'stub-idp-one', 'entityId' => 'http://idcorp.com'}]
      location = '/test-idp-request-endpoint'
      response = {'location' => location, 'samlRequest' => 'a-saml-request', 'relayState' => 'a-relay-state', 'registration' => false}
      stub_request(:get, api_uri('session/idps')).to_return(body: body.to_json)
      stub_request(:put, api_uri('session/select-idp')).to_return(status: 200)
      stub_request(:get, api_uri('session/idp-authn-request')).with(query: {'originatingIp' => '<PRINCIPAL IP ADDRESS COULD NOT BE DETERMINED>'}).to_return(body: response.to_json)
      set_session_cookies!
      visit '/sign-in'
      click_button('IDCorp')
      expect(a_request(:put, api_uri('session/select-idp'))).to have_been_made.once
      expect(a_request(:get, api_uri('session/idp-authn-request')).with(query: {'originatingIp' => '<PRINCIPAL IP ADDRESS COULD NOT BE DETERMINED>'})).to have_been_made.once
      expect(page).to have_current_path(location)
      expect(page).to have_content("SAML Request is 'a-saml-request'")
      expect(page).to have_content("relay state is 'a-relay-state'")
      expect(page).to have_content("registration is 'false'")
    end
  end

  context 'with JS disabled' do
    it 'will display the interstitial page'
  end
end
