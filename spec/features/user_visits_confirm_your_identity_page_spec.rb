require 'feature_helper'

RSpec.describe 'When the user visits the confirm-your-identity page' do
  describe 'and the journey hint cookie is set' do
    before(:each) do
      stub_federation
      set_session_cookies!
    end

    it 'displays the page in Welsh' do
      set_journey_hint_cookie('http://idcorp.com')
      visit '/confirm-your-identity-cy'
      expect(page).to have_title 'Confirm your identity - GOV.UK Verify - GOV.UK'
      expect(page).to have_css 'html[lang=cy]'
    end

    it 'displays the page in English', js: true do
      set_journey_hint_cookie('http://idcorp.com')
      visit '/confirm-your-identity'
      expect(page).to have_title 'Confirm your identity - GOV.UK Verify - GOV.UK'
      expect(page).to have_css 'html[lang=en]'
    end

    it 'includes the appropriate feedback source' do
      set_journey_hint_cookie('http://idcorp.com')
      visit '/confirm-your-identity'
      expect_feedback_source_to_be(page, 'CONFIRM_YOUR_IDENTITY')
    end

    it 'includes rp display name in text' do
      set_journey_hint_cookie('http://idcorp.com')
      visit '/confirm-your-identity'
      expect(page).to have_text 'In order to Register for an identity profile'
    end

    it 'should include a link to sign-in in case listed idp is incorrect' do
      set_journey_hint_cookie('http://idcorp.com')
      visit '/confirm-your-identity'
      expect(page).to have_link 'sign in with a different certified company', href: '/sign-in'
    end

    it 'should display only the idp that the user last verified with'do
      set_journey_hint_cookie('http://idcorp.com')
      visit '/confirm-your-identity'
      expect(page).to have_button 'Select IDCorp'
      expect(page).to have_css('.company', count: 1)
    end
  end

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
