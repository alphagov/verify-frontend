require 'feature_helper'
require 'api_test_helper'
require 'piwik_test_helper'

describe 'user sends authn requests' do
  context 'and it is received successfully' do
    let(:session_start_time) { Time.now }
    it 'will redirect the user to /start' do
      stub_session_creation

      visit('/test-saml')
      click_button 'saml-post'

      expect(page).to have_title t('hub.start.title')

      expect(page.get_rack_session['transaction_simple_id']).to eql 'test-rp'
      expect(page.get_rack_session['verify_session_id']).to eql default_session_id
      expect(page.get_rack_session['transaction_homepage']).to eql 'www.example.com'
      expect(page.get_rack_session['requested_loa']).to eql 'LEVEL_1'

      cookies = Capybara.current_session.driver.browser.rack_mock_session.cookie_jar
      expected_cookies = CookieNames.session_cookies + [
        CookieNames::VERIFY_LOCALE, CookieNames::AB_TEST, CookieNames::PIWIK_USER_ID
      ]

      expect(cookies.to_hash.keys.to_set).to eql expected_cookies.to_set
      expect(page.get_rack_session['transaction_supports_eidas']).to eql false
    end

    it 'will redirect the user to /choose-a-country for an eidas journey where eidas is enabled' do
      stub_session_creation('transactionSupportsEidas' => true)
      stub_transactions_list
      stub_countries_list

      visit('/test-saml')
      click_button 'saml-post-eidas'

      expect(page).to have_title t('hub.choose_a_country.title')
      expect(page.get_rack_session['transaction_supports_eidas']).to eql true
    end

    it 'will redirect the user to /about when journey hint is set to registration' do
      stub_session_creation
      stub_piwik_request = stub_piwik_journey_type_request(
        'REGISTRATION',
        'The user started a registration journey',
        'LEVEL_1'
      )
      visit('/test-saml')
      click_button 'saml-post-journey-hint-registration'

      expect(page).to have_title t('hub.about.title')
      expect(stub_piwik_request).to have_been_made.once
    end

    it 'will redirect the user to /sign-in when journey hint is set to sign_in' do
      stub_api_idp_list_for_sign_in(default_idps)
      stub_session_creation
      stub_piwik_request = stub_piwik_journey_type_request(
        'SIGN_IN',
        'The user started a sign-in journey',
        'LEVEL_1'
      )
      visit('/test-saml')
      click_button 'saml-post-journey-hint-sign-in'

      expect(page).to have_title t('hub.signin.title')
      expect(stub_piwik_request).to have_been_made.once
    end

    it 'will redirect the user to /continue-with-your-idp when user has a single idp cookie' do
      stub_session_creation
      stub_transactions_for_single_idp_list
      stub_api_idp_list_for_single_idp_journey

      visit('/test-single-idp-journey')
      click_button 'initiate-single-idp-post'

      visit('/test-saml')
      click_button 'saml-post-journey-hint-sign-in'

      expect(page).to have_title t('hub.single_idp_journey.title', display_name: 'IDCorp')
    end

    it 'will set ab_test cookie' do
      stub_session_creation

      visit('/test-saml')
      click_button 'saml-post'

      expect(cookie_value(CookieNames::AB_TEST)).to match(/{"select_documents_v2":"select_documents_v2_control","about_companies":"about_companies_with_logo".*}/)
    end

    it 'will not set ab_test cookie if already set' do
      stub_session_creation
      ab_test_cookie_value = {
        'about_companies' => 'about_companies_with_logo',
        'select_documents_v2' => 'select_documents_v2_control'
      }.to_json
      cookie_hash = create_cookie_hash.merge!(ab_test: CGI.escape(ab_test_cookie_value))
      set_cookies!(cookie_hash)

      visit('/test-saml')
      click_button 'saml-post'

      expect_cookie(CookieNames::AB_TEST, ab_test_cookie_value)
    end

    it 'will include both experiments in the ab_test cookie if only one experiment is currently in the ab_test cookie' do
      stub_session_creation
      cookie_hash = create_cookie_hash.merge!(ab_test: CGI.escape({ 'about_companies' => 'about_companies_no_logo' }.to_json))
      set_cookies!(cookie_hash)

      visit('/test-saml')
      click_button 'saml-post'

      expect(cookie_value(CookieNames::AB_TEST)).to match(/{"select_documents_v2":"select_documents_v2_control","about_companies":"about_companies_no_logo".*}/)
    end

    it 'will not set ab_test cookie if RP is in AB test blacklist' do
      stub_session_creation('simpleId' => 'test-rp-no-ab-test')

      visit('/test-saml')
      click_button 'saml-post'

      expect(cookie_value(CookieNames::AB_TEST)).to eql nil
    end
  end

  context 'and it is not received successfully' do
    it 'will render the something went wrong page' do
      allow(Rails.logger).to receive(:error)
      expect(Rails.logger).to receive(:error).with(kind_of(Api::Error)).at_least(:once)
      stub_session_creation_error
      stub_transactions_list
      visit('/test-saml')
      click_button 'saml-post'
      expect(page).to have_content t('errors.something_went_wrong.heading')
    end
  end
end
