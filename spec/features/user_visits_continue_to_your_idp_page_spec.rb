require 'feature_helper'
require 'api_test_helper'
require 'piwik_test_helper'

RSpec.describe 'When the user visits the continue to your IDP page' do
  let(:originating_ip) { '<PRINCIPAL IP ADDRESS COULD NOT BE DETERMINED>' }
  let(:encrypted_entity_id) { 'an-encrypted-entity-id' }
  let(:location) { '/test-idp-request-endpoint' }
  let(:idp_entity_id) { 'http://idcorp.com' }
  let(:idp_display_name) { 'IDCorp' }
  let(:select_idp_stub_request) {
    stub_session_select_idp_request(
      encrypted_entity_id,
      PolicyEndpoints::PARAM_SELECTED_ENTITY_ID => idp_entity_id, PolicyEndpoints::PARAM_PRINCIPAL_IP => originating_ip,
      PolicyEndpoints::PARAM_REGISTRATION => false, PolicyEndpoints::PARAM_REQUESTED_LOA => 'LEVEL_2',
      PolicyEndpoints::PARAM_ANALYTICS_SESSION_ID => piwik_session_id, PolicyEndpoints::PARAM_JOURNEY_TYPE => 'single-idp'
    )
  }
  let(:set_single_idp_journey_cookie) {
    visit '/test-single-idp-journey'
    click_button 'initiate-single-idp-post'
  }

  context 'javascript disabled' do
    before(:each) do
      set_session_and_session_cookies!(cookie_hash: create_cookie_hash_with_piwik_session)
      stub_transactions_for_single_idp_list
      stub_api_idp_list_for_single_idp_journey
    end

    it 'includes the appropriate feedback source, page title and piwik custom variable' do
      set_single_idp_journey_cookie
      visit '/continue-to-your-idp'

      expect(page).to have_current_path('/continue-to-your-idp')
      expect(page).to have_title t('hub.single_idp_journey.title', display_name: idp_display_name)
      expect_feedback_source_to_be(page, 'CONTINUE_TO_YOUR_IDP_PAGE', '/continue-to-your-idp')
      piwik_custom_variable_single_idp_journey = '{"index":3,"name":"JOURNEY_TYPE","value":"SINGLE_IDP","scope":"visit"}'
      expect(page).to have_content(piwik_custom_variable_single_idp_journey)
    end

    it 'supports the welsh language' do
      set_single_idp_journey_cookie
      visit '/parhau-ich-idp'

      expect(page).to have_title t('hub.single_idp_journey.title', locale: :cy, display_name: 'Welsh IDCorp')
      expect(page).to have_css 'html[lang=cy]'
    end

    it 'should show the user the start page if the cookie is missing' do
      visit '/continue-to-your-idp'

      expect(page).to have_content t('hub.start.heading')
    end

    it 'goes to "redirect-to-idp" page on submit' do
      set_single_idp_journey_cookie
      visit '/continue-to-your-idp'

      select_idp_stub_request
      stub_session_idp_authn_request(originating_ip, location, false)

      click_button t('hub.single_idp_journey.continue_button', display_name: idp_display_name)

      expect(page).to have_current_path(redirect_to_single_idp_path)
      expect(select_idp_stub_request).to have_been_made.once
      expect(stub_piwik_request('action_name' => "Single IDP selected - #{idp_display_name}")).to have_been_made.once
    end
  end

  context 'with JS enabled', js: true do
    def single_idp_session
      {
          transaction_simple_id: 'test-rp-noc3',
          start_time: start_time_in_millis,
          verify_session_id: default_session_id,
          requested_loa: 'LEVEL_2',
          transaction_entity_id: 'some-other-entity-id',
          selected_answers: { device_type: { device_type_other: true } },
      }
    end

    before(:each) do
      set_session_and_session_cookies!(cookie_hash: create_cookie_hash_with_piwik_session, session: single_idp_session)
      stub_transactions_for_single_idp_list
      stub_api_idp_list_for_single_idp_journey('some-other-entity-id')
      visit '/test-single-idp-journey'
      # javascript driver needs a redirect to a real page
      fill_in('serviceId', with: 'some-other-entity-id')
      click_button 'initiate-single-idp-post'
    end

    it 'will redirect the user to the IDP on Continue' do
      visit '/continue-to-your-idp'
      select_idp_stub_request
      stub_session_idp_authn_request(originating_ip, location, false)
      expect_any_instance_of(SingleIdpJourneyController).to receive(:continue_ajax).and_call_original

      click_button t('hub.single_idp_journey.continue_button', display_name: idp_display_name)
      expect(stub_piwik_request('action_name' => "Single IDP selected - #{idp_display_name}")).to have_been_made.once
      expect(page).to have_current_path(location)
      expect(page).to have_content("SAML Request is 'a-saml-request'")
      expect(page).to have_content("relay state is 'a-relay-state'")
      expect(page).to have_content("registration is 'false'")
      expect(page).to have_content("language hint was 'en'")
      expect(page).to have_content("single IDP journey uuid is ")
      expect(select_idp_stub_request).to have_been_made.once
    end
  end
end
