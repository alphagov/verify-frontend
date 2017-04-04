require 'feature_helper'
require 'api_test_helper'
require 'models/session_proxy'
require 'piwik_test_helper'

RSpec.describe 'user sends authn requests' do
  let(:api_saml_endpoint) { api_uri('session') }

  context 'and it is received successfully' do
    let(:session_start_time) { DateTime.now }
    it 'will redirect the user to /start' do
      stub_api_saml_endpoint

      visit('/test-saml')
      click_button 'saml-post'

      expect(page).to have_title 'Start - GOV.UK Verify - GOV.UK'

      expect(page.get_rack_session['transaction_simple_id']).to eql 'test-rp'
      expect(page.get_rack_session['verify_session_id']).to eql default_session_id
      expect(page.get_rack_session['identity_providers']).to eql [{ 'simple_id' => 'stub-idp-one', 'entity_id' => 'http://idcorp.com' }]
      expect(page.get_rack_session['requested_loa']).to eql 'LEVEL_1'

      cookies = Capybara.current_session.driver.browser.rack_mock_session.cookie_jar
      expected_cookies = CookieNames.session_cookies + [
        CookieNames::VERIFY_LOCALE, CookieNames::AB_TEST
      ]

      expect(cookies.to_hash.keys.to_set).to eql expected_cookies.to_set
      expect(page.get_rack_session['transaction_supports_eidas']).to eql false
    end

    it 'will redirect the user to /confirm-your-identity when journey hint is set' do
      set_journey_hint_cookie('http://idcorp.com')
      stub_api_saml_endpoint(transaction_supports_eidas: true)
      visit('/test-saml')
      click_button 'saml-post-journey-hint'
      expect(page).to have_title 'Confirm your identity - GOV.UK Verify - GOV.UK'
      expect(page.get_rack_session['transaction_supports_eidas']).to eql true
    end

    it 'will redirect the user to /choose-a-country for an eidas journey where eidas is enabled' do
      stub_api_saml_endpoint(transaction_supports_eidas: true)
      stub_transactions_list
      stub_countries_list

      visit('/test-saml')
      click_button 'saml-post-eidas'

      expect(page).to have_title 'Choose a country - GOV.UK Verify - GOV.UK'
      expect(page.get_rack_session['transaction_supports_eidas']).to eql true
    end

    it 'will render the something went wrong page for an eidas journey where eidas is disabled' do
      stub_api_saml_endpoint(transaction_supports_eidas: false)
      stub_transactions_list

      visit('/test-saml')
      click_button 'saml-post-eidas'

      expect(page).to have_content 'Sorry, something went wrong'
      expect(page.get_rack_session['transaction_supports_eidas']).to eql false
    end
  end

  context 'and it is not received successfully' do
    it 'will render the something went wrong page' do
      allow(Rails.logger).to receive(:error)
      expect(Rails.logger).to receive(:error).with(kind_of(Api::Error)).at_least(:once)
      stub_request(:post, api_saml_endpoint).to_return(body: '{"message": "error"}', status: 500)
      stub_transactions_list
      visit('/test-saml')
      click_button 'saml-post'
      expect(page).to have_content 'Sorry, something went wrong'
    end
  end
end
