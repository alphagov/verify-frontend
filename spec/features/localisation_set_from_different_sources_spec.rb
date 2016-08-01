require 'feature_helper'
require 'api_test_helper'

RSpec.describe 'locale is set based on multiple sources', type: :feature do
  context "when I visit a page" do
    it 'will set the locale cookie to en if the language is English', js: true do
      set_session_cookies!
      visit start_path
      expect(cookie_value(CookieNames::VERIFY_LOCALE)).to have_a_signed_value_of 'en'
    end

    it 'will set the locale cookie to cy if the page language is Welsh', js: true do
      set_session_cookies!
      visit about_cy_path
      expect(cookie_value(CookieNames::VERIFY_LOCALE)).to have_a_signed_value_of 'cy'
    end

    it 'will change the value of the locale cookie when the user changes from English to Welsh', js: true do
      set_session_cookies!
      visit start_path
      expect(cookie_value(CookieNames::VERIFY_LOCALE)).to have_a_signed_value_of 'en'
      click_on 'Cymraeg'
      expect(cookie_value(CookieNames::VERIFY_LOCALE)).to have_a_signed_value_of 'cy'
    end
  end

  context "when submitting saml" do
    RSpec.shared_examples "submitting SAML" do |locale|
      it "will render the start page in #{locale} after SAML submission when locale cookie set to #{locale}", js: true do
        set_session_cookies!
        visit public_send("about_#{locale}_path")
        expect(cookie_value(CookieNames::VERIFY_LOCALE)).to have_a_signed_value_of locale
        stub_federation
        stub_api_saml_endpoint

        visit('/test-saml')
        click_button 'saml-post'

        expect(current_path).to eql(public_send("start_#{locale}_path"))
      end

      it "will render the response processing page in #{locale} after SAML response when locale cookie set to #{locale}", js: true do
        session_cookies = set_session_cookies!
        visit public_send("about_#{locale}_path")
        expect(cookie_value(CookieNames::VERIFY_LOCALE)).to have_a_signed_value_of locale
        stub_matching_outcome
        session_id = session_cookies[CookieNames::SESSION_ID_COOKIE_NAME]
        stub_api_response(session_id, 'idpResult' => 'SUCCESS', 'isRegistration' => false)

        visit('/test-saml')
        click_button 'saml-response-post'

        expect(current_path).to eql(public_send("response_processing_#{locale}_path"))
      end

      private

      def stub_api_response(relay_state, response)
        authn_response_body = {
            SessionProxy::PARAM_SAML_RESPONSE => 'my-saml-response',
            SessionProxy::PARAM_RELAY_STATE => relay_state,
            SessionProxy::PARAM_ORIGINATING_IP => '<PRINCIPAL IP ADDRESS COULD NOT BE DETERMINED>'
        }

        stub_request(:put, api_uri('session/idp-authn-response'))
            .with(body: authn_response_body)
            .to_return(body: response.to_json, status: 200)
      end
    end

    include_examples "submitting SAML", 'en'
    include_examples "submitting SAML", 'cy'

    it "will render the start page in English when no cookie or form parameters are set" do
      stub_federation
      stub_api_saml_endpoint

      visit('/test-saml')
      click_button 'saml-post'

      expect(current_path).to eql(start_en_path)
    end
  end
end

