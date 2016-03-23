require 'feature_helper'

def given_api_requests_have_been_mocked!
  body = { 'idps' => [{ 'simpleId' => 'stub-idp-one', 'entityId' => 'http://idcorp.com' }], 'transactionEntityId' => 'some-id' }
  stub_request(:get, api_uri('session/federation')).to_return(body: body.to_json)
  stub_request(:put, api_uri('session/select-idp'))
    .to_return(body: { 'encryptedEntityId' => encrypted_entity_id }.to_json)
  stub_request(:get, api_uri('session/idp-authn-request'))
    .with(query: { 'originatingIp' => originating_ip }).to_return(body: response.to_json)
  stub_request(:get, INTERNAL_PIWIK.url).with(query: hash_including({}))
end

def given_im_on_the_sign_in_page
  cookies
  visit '/sign-in'
end

def when_i_select_an_idp
  click_button('IDCorp')
end

def then_im_at_the_idp
  expect(page).to have_current_path(location)
  expect(page).to have_content("SAML Request is 'a-saml-request'")
  expect(page).to have_content("relay state is 'a-relay-state'")
  expect(page).to have_content("registration is 'false'")
  expect_cookie('verify-journey-hint', encrypted_entity_id)
  expect(a_request(:put, api_uri('session/select-idp'))
           .with(body: { 'entityId' => idp_entity_id, 'originatingIp' => originating_ip })).to have_been_made.once
  expect(a_request(:get, api_uri('session/idp-authn-request'))
           .with(query: { 'originatingIp' => originating_ip })).to have_been_made.once
  piwik_request = {
      '_cvar' => "{\"3\":[\"SIGNIN_IDP\",\"#{idp_entity_id}\"]}",
      'action_name' => 'Sign In - ' + idp_entity_id,
  }
  expect(a_request(:get, INTERNAL_PIWIK.url).with(query: hash_including(piwik_request))).to have_been_made.once
end

def then_im_at_the_interstitial_page
  expect(page).to have_current_path('/redirect-to-idp')
end

def when_i_choose_to_continue
  click_button('continue')
end

RSpec.describe 'user selects an IDP on the sign in page' do
  let(:idp_entity_id) { 'http://idcorp.com' }
  let(:body) {
    [
      { 'simpleId' => 'stub-idp-zero', 'entityId' => 'idp-zero' },
      { 'simpleId' => 'stub-idp-one', 'entityId' => idp_entity_id },
      { 'simpleId' => 'stub-idp-two', 'entityId' => 'idp-two' },
      { 'simpleId' => 'stub-idp-three', 'entityId' => 'idp-three' },
      { 'simpleId' => 'stub-idp-four', 'entityId' => 'idp-four' }
    ]
  }
  let(:location) { '/test-idp-request-endpoint' }
  let(:response) {
    {
      'location' => location,
      'samlRequest' => 'a-saml-request',
      'relayState' => 'a-relay-state',
      'registration' => false
    }
  }
  let(:originating_ip) { '<PRINCIPAL IP ADDRESS COULD NOT BE DETERMINED>' }
  let(:encrypted_entity_id) { 'an-encrypted-entity-id' }
  let(:cookies) { set_session_cookies! }

  context 'with JS enabled', js: true do
    it 'will redirect the user to the IDP' do
      given_api_requests_have_been_mocked!
      given_im_on_the_sign_in_page
      when_i_select_an_idp
      then_im_at_the_idp
    end
  end

  context 'with JS disabled', js: false do
    it 'will display the interstitial page and on submit will redirect the user to IDP' do
      given_api_requests_have_been_mocked!
      given_im_on_the_sign_in_page
      when_i_select_an_idp
      then_im_at_the_interstitial_page
      when_i_choose_to_continue
      then_im_at_the_idp
    end
  end
end
