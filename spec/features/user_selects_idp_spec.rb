require 'feature_helper'

RSpec.describe 'user selects an IDP on the sign in page' do
  context 'with JS enabled', js: true do
    it 'will redirect the user to the IDP' do
      idp_entity_id = 'http://idcorp.com'
      body = [{'simpleId' => 'stub-idp-one', 'entityId' => idp_entity_id}]
      location = '/test-idp-request-endpoint'
      response = {'location' => location, 'samlRequest' => 'a-saml-request',
        'relayState' => 'a-relay-state', 'registration' => false}
      originating_ip = '<PRINCIPAL IP ADDRESS COULD NOT BE DETERMINED>'

      stub_request(:get, api_uri('session/idps')).to_return(body: body.to_json)
      stub_request(:put, api_uri('session/select-idp')).to_return(status: 200)
      stub_request(:get, api_uri('session/idp-authn-request'))
        .with(query: {'originatingIp' => originating_ip}).to_return(body: response.to_json)
      set_session_cookies!
      visit '/sign-in'
      click_button('IDCorp')
      expect(a_request(:put, api_uri('session/select-idp'))
        .with(body: {'entityId' => idp_entity_id, 'originatingIp' => originating_ip})).to have_been_made.once
      expect(a_request(:get, api_uri('session/idp-authn-request'))
        .with(query: {'originatingIp' => originating_ip})).to have_been_made.once
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
