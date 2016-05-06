require 'feature_helper'
require 'api_test_helper'
require 'models/session_proxy'

RSpec.describe 'user sends authn requests' do
  let(:api_saml_endpoint) { api_uri('session') }
  context 'and it is received successfully' do
    let(:session_start_time) { current_time_in_millis }
    it 'will redirect the user to /start' do
      stub_federation
      session = {
          'transactionSimpleId' => 'my_transaction_simple_id',
          'sessionStartTime' => '32503680000000',
          'sessionId' => 'session_id',
          'secureCookie' => 'secure_cookie'
      }
      authn_request_body = {
          SessionProxy::PARAM_SAML_REQUEST => 'my-saml-request',
          SessionProxy::PARAM_RELAY_STATE => 'my-relay-state',
          SessionProxy::PARAM_ORIGINATING_IP => '<PRINCIPAL IP ADDRESS COULD NOT BE DETERMINED>'
      }
      stub_request(:post, api_saml_endpoint).with(body: authn_request_body).to_return(body: session.to_json, status: 201)

      visit('/test-saml')
      click_button 'saml-post'

      expect(page).to have_title 'Start - GOV.UK Verify - GOV.UK'

      expect(page.get_rack_session['transaction_simple_id']).to eql 'my_transaction_simple_id'
      expect(cookie_value(CookieNames::SECURE_COOKIE_NAME)).not_to be_empty

      cookies = Capybara.current_session.driver.request.cookies
      expected_cookies = (CookieNames.session_cookies << '_verify-frontend_session').to_set

      expect(cookies.keys.to_set).to eql expected_cookies
    end

    it 'will redirect the user to /confirm-your-identity when journey hint is set' do
      set_journey_hint_cookie('http://idcorp.com')
      stub_federation
      session = {
          'transactionSimpleId' => 'my_transaction_simple_id',
          'sessionStartTime' => '32503680000000',
          'sessionId' => 'session_id',
          'secureCookie' => 'secure_cookie'
      }
      authn_request_body = {
          SessionProxy::PARAM_SAML_REQUEST => 'my-saml-request',
          SessionProxy::PARAM_RELAY_STATE => 'my-relay-state',
          SessionProxy::PARAM_ORIGINATING_IP => '<PRINCIPAL IP ADDRESS COULD NOT BE DETERMINED>'
      }
      stub_request(:post, api_saml_endpoint).with(body: authn_request_body).to_return(body: session.to_json, status: 201)
      visit('/test-saml')
      click_button 'saml-post-journey-hint'
      expect(page).to have_title 'Confirm your identity - GOV.UK Verify - GOV.UK'
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
