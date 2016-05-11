require 'feature_helper'
require 'api_test_helper'

def stub_api_and_analytics(idp_location)
  stub_federation
  stub_session_select_idp_request('an-encrypted-entity-id')
  stub_session_idp_authn_request(originating_ip, idp_location, false)
  stub_request(:get, INTERNAL_PIWIK.url).with(query: hash_including({}))
end

def set_up_session(idp_entity_id)
  stub_api_and_analytics(idp_location)
  set_session_cookies!
  set_journey_hint_cookie(idp_entity_id)
  page.set_rack_session(transaction_simple_id: 'test-rp')
end

RSpec.describe 'When the user visits the confirm-your-identity page' do
  let(:idp_location) { '/test-idp-request-endpoint' }
  let(:originating_ip) { '<PRINCIPAL IP ADDRESS COULD NOT BE DETERMINED>' }

  describe 'and the journey hint cookie is set' do
    before(:each) do
      set_up_session('http://idcorp.com')
    end

    it 'displays the page in Welsh' do
      visit '/confirm-your-identity-cy'
      expect(page).to have_title 'Cadarnhau eich hunaniaeth - GOV.UK Verify - GOV.UK'
      expect(page).to have_css 'html[lang=cy]'
    end

    it 'displays the page in English' do
      visit '/confirm-your-identity'
      expect(page).to have_title 'Confirm your identity - GOV.UK Verify - GOV.UK'
      expect(page).to have_css 'html[lang=en]'
    end

    it 'includes the appropriate feedback source' do
      visit '/confirm-your-identity'
      expect_feedback_source_to_be(page, 'CONFIRM_YOUR_IDENTITY')
    end

    it 'includes rp display name in text' do
      visit '/confirm-your-identity'
      expect(page).to have_text 'In order to register for an identity profile'
    end

    it 'should include a link to sign-in in case listed idp is incorrect' do
      visit '/confirm-your-identity'
      expect(page).to have_link 'sign in with a different certified company', href: '/sign-in'
    end

    it 'should display only the idp that the user last verified with' do
      visit '/confirm-your-identity'
      expect(page).to have_button 'Sign in with IDCorp'
      expect(page).to have_css('.company', count: 1)
    end

    describe 'and js is disabled' do
      it 'should display the interstitial page' do
        visit '/confirm-your-identity'
        click_button 'Sign in with IDCorp'
        expect(page).to have_current_path('/redirect-to-idp')
        click_button 'Continue'
        expect(page).to have_current_path(idp_location)
      end
    end

    describe 'and js is enabled', js: true do
      it 'should redirect to the IDP sign in page' do
        visit '/confirm-your-identity'
        click_button 'Sign in with IDCorp'
        expect(page).to have_current_path(idp_location)
      end

      it 'should allow the user to select a new IDP and update the cookie' do
        # User has previously chosen IDCorp
        visit '/confirm-your-identity'
        expect(page).to have_button('Sign in with IDCorp')

        # User returns to sign in page and selects a new IDP
        click_link 'sign in with a different certified company'
        new_idp_location = '/another-idp-endpoint'
        stub_api_and_analytics(new_idp_location)
        click_button 'Select Bob'
        expect(page).to have_current_path(new_idp_location)

        # The new IDP is displayed for non-repudiation
        visit '/confirm-your-identity'
        click_button 'Sign in with Bob'
        expect(page).to have_current_path(new_idp_location)
      end
    end
  end

  describe 'and the journey hint cookie is invalid in some way' do
    it 'should redirect to sign in page when the journey cookie is not set' do
      stub_federation
      set_session_cookies!
      visit '/confirm-your-identity'
      expect(page).to have_title 'Sign in with a certified company - GOV.UK Verify - GOV.UK'
      expect(page).to have_current_path(sign_in_path)
    end

    it 'should redirect to sign in page when the journey cookie has a nil value' do
      stub_federation
      set_session_cookies!
      visit '/confirm-your-identity'
      expect(page).to have_title 'Sign in with a certified company - GOV.UK Verify - GOV.UK'
      expect(page).to have_current_path(sign_in_path)
    end

    it 'should redirect to sign in page when the journey cookie has an invalid entity ID' do
      set_up_session('bad-entity-id')
      visit '/confirm-your-identity'
      expect(page).to have_title 'Sign in with a certified company - GOV.UK Verify - GOV.UK'
      expect(page).to have_current_path(sign_in_path)
      expect(cookie_value(CookieNames::VERIFY_FRONT_JOURNEY_HINT)).to eql(nil)
    end
  end

  describe 'when the user changes language', js: true do
    it 'will preserve the language from sign-in' do
      set_up_session('stub-idp-one')
      stub_api_saml_endpoint
      visit '/sign-in'
      click_link 'Cymraeg'
      expect(page).to have_current_path('/mewngofnodi')
      click_button 'IDCorp'

      visit '/test-saml'
      click_button 'saml-post-journey-hint'
      expect(page).to have_title 'Cadarnhau eich hunaniaeth - GOV.UK Verify - GOV.UK'
      expect(page).to have_current_path('/confirm-your-identity-cy')
      expect(page).to have_css 'html[lang=cy]'
    end

    it 'will preserve the language from redirect-to-idp-warning' do
      page.set_rack_session(
        selected_idp: { entity_id: 'http://idcorp.com', simple_id: 'stub-idp-one' },
        selected_idp_was_recommended: true,
        selected_evidence: { phone: %w(mobile_phone smart_phone), documents: %w(passport) },
      )
      set_up_session('stub-idp-one')

      visit '/redirect-to-idp-warning'

      click_link 'Cymraeg'
      expect(page).to have_current_path('/ailgyfeirio-i-rybudd-idp')
      click_button 'IDCorp'

      stub_api_saml_endpoint
      visit '/test-saml'
      click_button 'saml-post-journey-hint'

      expect(page).to have_title 'Cadarnhau eich hunaniaeth - GOV.UK Verify - GOV.UK'
      expect(page).to have_current_path('/confirm-your-identity-cy')
      expect(page).to have_css 'html[lang=cy]'
    end
  end
end
