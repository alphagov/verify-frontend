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

      expect(page).to have_title 'Start - GOV.UK Verify - GOV.UK'

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

    it 'will redirect the user to /confirm-your-identity when journey hint is set' do
      stub_api_idp_list(default_idps, 'LEVEL_1')
      set_journey_hint_cookie('http://idcorp.com')
      stub_session_creation('transactionSupportsEidas' => true)
      visit('/test-saml')
      click_button 'saml-post-journey-hint'
      expect(page).to have_title 'Confirm your identity - GOV.UK Verify - GOV.UK'
      expect(page.get_rack_session['transaction_supports_eidas']).to eql true
    end

    it 'will redirect the user to /choose-a-country for an eidas journey where eidas is enabled' do
      stub_session_creation('transactionSupportsEidas' => true)
      stub_transactions_list
      stub_countries_list

      visit('/test-saml')
      click_button 'saml-post-eidas'

      expect(page).to have_title 'Choose a country - GOV.UK Verify - GOV.UK'
      expect(page.get_rack_session['transaction_supports_eidas']).to eql true
    end

    it 'will render the something went wrong page for an eidas journey where eidas is disabled' do
      stub_session_creation('transactionSupportsEidas' => false)
      stub_transactions_list

      visit('/test-saml')
      click_button 'saml-post-eidas'

      expect(page).to have_content 'Sorry, something went wrong'
      expect(page.get_rack_session['transaction_supports_eidas']).to eql false
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
        'select_documents_v2' => 'select_documents_v2_control',
        'threshold_policy_experiment' => 'threshold_policy_experiment_control',
        'clever_questions' => 'clever_questions_control',
        'loa1_shortened_journey_v3' => 'loa1_shortened_journey_v3_control'
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
      expect(page).to have_content 'Sorry, something went wrong'
    end
  end
end
