require 'feature_helper'

RSpec.describe 'When the user visits the confirm-your-identity page' do
  let(:idp_location) { '/test-idp-request-endpoint' }
  let(:encrypted_entity_id) { 'an-encrypted-entity-id' }
  let(:originating_ip) { '<PRINCIPAL IP ADDRESS COULD NOT BE DETERMINED>' }

  def response(location)
    {
        'location' => location,
        'samlRequest' => 'a-saml-request',
        'relayState' => 'a-relay-state',
        'registration' => false
    }
  end

  def stub_api_and_analytics(idp_location)
    stub_federation
    stub_request(:put, api_uri('session/select-idp'))
        .to_return(body: { 'encryptedEntityId' => encrypted_entity_id }.to_json)
    stub_request(:get, api_uri('session/idp-authn-request'))
        .with(query: { 'originatingIp' => originating_ip }).to_return(body: response(idp_location).to_json)
    stub_request(:get, INTERNAL_PIWIK.url).with(query: hash_including({}))
  end

  describe 'and the journey hint cookie is set' do
    before(:each) do
      stub_api_and_analytics(idp_location)
      set_session_cookies!
      set_journey_hint_cookie('http://idcorp.com')
    end

    it 'displays the page in Welsh' do
      visit '/confirm-your-identity-cy'
      expect(page).to have_title 'Confirm your identity - GOV.UK Verify - GOV.UK'
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
      expect(page).to have_text 'In order to Register for an identity profile'
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
      stub_federation
      set_session_cookies!
      set_journey_hint_cookie('bad-entity-id')
      visit '/confirm-your-identity'
      expect(page).to have_title 'Sign in with a certified company - GOV.UK Verify - GOV.UK'
      expect(page).to have_current_path(sign_in_path)
      expect(cookie_value(CookieNames::VERIFY_FRONT_JOURNEY_HINT)).to eql(nil)
    end
  end
end
