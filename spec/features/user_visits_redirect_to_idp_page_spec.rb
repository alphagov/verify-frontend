require 'feature_helper'
require 'api_test_helper'

RSpec.describe 'When the user visits the redirect to IDP page' do
  let(:originating_ip) { '<PRINCIPAL IP ADDRESS COULD NOT BE DETERMINED>' }
  let(:location) { '/test-idp-request-endpoint' }
  let(:selected_answers) { { phone: { mobile_phone: true, smart_phone: false }, documents: { passport: true } } }
  let(:idp_entity_id) { 'http://idcorp.com' }
  let(:given_a_session_with_a_hints_enabled_idp) {
    page.set_rack_session(
      selected_idp: { entity_id: idp_entity_id, simple_id: 'stub-idp-one' },
      selected_idp_was_recommended: true,
      selected_answers: selected_answers,
    )
  }
  let(:given_a_session_with_a_hints_disabled_idp) {
    page.set_rack_session(
      selected_idp: { entity_id: idp_entity_id, simple_id: 'stub-idp-two' },
      selected_idp_was_recommended: true,
      selected_answers: selected_answers,
    )
  }

  before(:each) do
    set_session_cookies!
  end

  it 'should contain hint inputs if hints are enabled for the IDP' do
    given_a_session_with_a_hints_enabled_idp
    stub_session_idp_authn_request(originating_ip, location, true)
    visit redirect_to_idp_path
    expect(page).to have_css('input[name="hint"][value="has_ukpassport"]')
    expect(page).to have_css('input[name="hint"][value="not_apps"]')
    expect(page).to_not have_css('input[name="hint"][value="has_nonukid"]')
  end

  it 'should not contain hint inputs if hints are disabled for the IDP' do
    given_a_session_with_a_hints_disabled_idp
    stub_session_idp_authn_request(originating_ip, location, true)
    visit redirect_to_idp_path
    expect(page).to_not have_css('input[name="hint"]')
  end

  it 'should not contain hint input if user is signing in' do
    given_a_session_with_a_hints_enabled_idp
    stub_session_idp_authn_request(originating_ip, location, false)
    visit redirect_to_idp_path
    expect(page).to_not have_css('input[name="hint"]')
  end
end
