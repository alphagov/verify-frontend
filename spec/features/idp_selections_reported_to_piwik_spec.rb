require 'feature_helper'
require 'api_test_helper'
require 'piwik_test_helper'

RSpec.describe 'When the user selects an IDP' do
  let(:selected_answers) { { phone: { mobile_phone: true, smart_phone: true }, documents: { driving_licence: true, passport: true } } }
  let(:location) { '/test-idp-request-endpoint' }
  let(:idp_1_entity_id) { 'http://idcorp.com' }
  let(:idp_2_entity_id) { 'other-entity-id' }
  let(:idp_1_simple_id) { 'stub-idp-one' }
  let(:idp_2_simple_id) { 'stub-idp-two' }
  let(:given_a_session_with_selected_answers) {
    page.set_rack_session(
      selected_answers: selected_answers,
    )
  }

  let(:idcorp_registration_piwik_request) {
    stub_piwik_idp_registration('IDCorp', selected_answers: selected_answers, recommended: true)
  }

  let(:originating_ip) { '<PRINCIPAL IP ADDRESS COULD NOT BE DETERMINED>' }
  let(:encrypted_entity_id) { 'an-encrypted-entity-id' }

  before(:each) do
    set_session_and_session_cookies!
    stub_api_idp_list
    stub_transactions_list
    stub_session_idp_authn_request(originating_ip, location, false)
    stub_idp_select_request(idp_1_entity_id)
    stub_idp_select_request(idp_2_entity_id)
    given_a_session_with_selected_answers
  end

  it 'reports the IDP name to piwik' do
    piwik_registration_virtual_page = idcorp_registration_piwik_request

    visit '/choose-a-certified-company'
    click_button 'Choose IDCorp'
    click_button 'Continue to IDCorp'

    expect(piwik_registration_virtual_page).to have_been_made.once
  end


  it 'appends the IdP name on subsequent selections' do
    idcorp_piwik_request = idcorp_registration_piwik_request
    idcorp_and_bobs_piwik_request = stub_piwik_idp_registration(
      'Bob’s Identity Service',
      selected_answers: selected_answers,
      recommended: false,
      idp_list: 'IDCorp,Bob’s Identity Service'
    )
    visit '/choose-a-certified-company'
    click_button 'Choose IDCorp'
    click_button 'Continue to IDCorp'

    expect(idcorp_piwik_request).to have_been_made.once

    visit '/choose-a-certified-company'
    click_button 'Choose Bob’s Identity Service'
    click_button 'Continue to Bob’s Identity Service'

    expect(idcorp_and_bobs_piwik_request).to have_been_made.once
  end

  it 'truncates IdP names' do
    idps = %w(A B C D E)
    idcorp_piwik_request = stub_piwik_idp_registration('IDCorp', recommended: true, selected_answers: selected_answers, idp_list: idps.join(','))
    page.set_rack_session(selected_idp_names: idps)
    visit '/choose-a-certified-company'
    click_button 'Choose IDCorp'
    click_button 'Continue to IDCorp'

    expect(idcorp_piwik_request).to have_been_made.once
  end
end

def stub_idp_select_request(idp_entity_id)
  stub_session_select_idp_request(
    encrypted_entity_id,
    PolicyEndpoints::PARAM_SELECTED_ENTITY_ID => idp_entity_id, PolicyEndpoints::PARAM_PRINCIPAL_IP => originating_ip, PolicyEndpoints::PARAM_REGISTRATION => true
  )
end
