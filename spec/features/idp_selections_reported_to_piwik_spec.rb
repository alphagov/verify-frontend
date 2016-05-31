require 'feature_helper'
require 'api_test_helper'

RSpec.describe 'When the user selects an IDP' do
  let(:selected_evidence) { { phone: %w(mobile_phone smart_phone), documents: %w(passport) } }
  let(:location) { '/test-idp-request-endpoint' }
  let(:idp_1_entity_id) { 'http://idcorp.com' }
  let(:idp_2_entity_id) { 'other-entity-id' }
  let(:idp_1_simple_id) { 'stub-idp-one' }
  let(:idp_2_simple_id) { 'stub-idp-two' }

  let(:originating_ip) { '<PRINCIPAL IP ADDRESS COULD NOT BE DETERMINED>' }
  let(:encrypted_entity_id) { 'an-encrypted-entity-id' }

  before(:each) do
    set_session_cookies!
    stub_transactions_list
    stub_federation
    stub_session_idp_authn_request(originating_ip, location, false)
    stub_idp_select_request(idp_1_entity_id)
    stub_idp_select_request(idp_2_entity_id)
  end

  it 'reports the IDP name to piwik' do
    piwik_registration_virtual_page = stub_piwik_idp_selection('IDCorp')

    visit '/choose-a-certified-company'
    click_button 'Choose IDCorp'
    click_button 'Continue to IDCorp'

    expect(piwik_registration_virtual_page).to have_been_made.once
  end


  it 'appends the IdP name on subsequent selections' do
    idcorp_piwik_request = stub_piwik_idp_selection('IDCorp')
    idcorp_and_bobs_piwik_request = stub_piwik_idp_selection("IDCorp,Bob’s Identity Service")

    visit '/choose-a-certified-company'
    click_button 'Choose IDCorp'
    click_button 'Continue to IDCorp'

    expect(idcorp_piwik_request).to have_been_made.once

    visit '/choose-a-certified-company'
    click_button 'Choose Bob’s Identity Service'
    click_button 'Continue to Bob’s Identity Service'

    expect(idcorp_and_bobs_piwik_request).to have_been_made.once
  end
end

def stub_piwik_idp_selection(idp_name)
  piwik_request = {
      '_cvar' => "{\"5\":[\"IDP_SELECTION\",\"#{idp_name}\"]}",
      'action_name' => "IDP selection" #TODO clarify what the action name should be with Olly
  }
  stub_request(:get, INTERNAL_PIWIK.url).with(query: hash_including(piwik_request))
end

def stub_idp_select_request(idp_entity_id)
  stub_session_select_idp_request(
    encrypted_entity_id,
    'entityId' => idp_entity_id, 'originatingIp' => originating_ip, 'registration' => true
  )
end
