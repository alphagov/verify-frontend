require 'feature_helper'
require 'api_test_helper'
require 'i18n'

RSpec.describe 'When the user visits the redirect to IDP question page' do
  let(:originating_ip) { '<PRINCIPAL IP ADDRESS COULD NOT BE DETERMINED>' }
  let(:location) { '/test-idp-request-endpoint' }
  let(:given_an_idp_with_interstitial_question_needed) {
    page.set_rack_session(
      selected_idp: { entity_id: 'stub-idp-one-doc-question', simple_id: 'stub-idp-one-doc-question' },
      selected_idp_was_recommended: true,
    )
  }

  let(:select_idp_stub_request) {
    stub_session_select_idp_request(
      'an-encrypted-entity-id',
      'entityId' => 'stub-idp-one-doc-question', 'originatingIp' => originating_ip, 'registration' => true
    )
  }

  before(:each) do
    set_session_and_session_cookies!
    given_an_idp_with_interstitial_question_needed
    visit '/redirect-to-idp-question'
  end

  it 'displays a question' do
    expect(page).to have_content('Verifying with FancyPants')
    expect(page).to have_content('I have a question')
  end

  it 'goes to "redirect-to-idp" page if the user answers the question' do
    select_idp_stub_request
    stub_session_idp_authn_request(originating_ip, location, false)

    choose 'interstitial_question_form_extra_info_false', allow_label_click: true

    click_button 'Continue to FancyPants'

    expect(page).to have_current_path(redirect_to_idp_path)
    expect(select_idp_stub_request).to have_been_made.once
    expect(cookie_value('verify-front-journey-hint')).to_not be_nil
  end

  it 'displays an error message when user does not answer the question when javascript is turned off' do
    click_button 'Continue to FancyPants'
    expect(page).to have_current_path(redirect_to_idp_question_submit_path)
    expect(page).to have_content('Please answer the question')
  end

  context 'user fills more questions form', js: true do
    it 'should not say we cannot verify you when user selects yes' do
      choose 'interstitial_question_form_extra_info_true', allow_label_click: true
      expect(page).to_not have_content('may not be able to verify you')
    end

    it 'should say we may not be able to verify you when user selects no' do
      choose 'interstitial_question_form_extra_info_false', allow_label_click: true
      expect(page).to have_content('may not be able to verify you')
    end
  end

  context 'javascript validation', js: true do
    it 'should display validation message if no selection is made' do
      click_button 'Continue to FancyPants'
      expect(page).to have_content('Please answer the question')
    end

    it 'should remove validation message once selection is made' do
      click_button 'Continue to FancyPants'
      expect(page).to have_content('Please answer the question')
      choose 'interstitial_question_form_extra_info_false', allow_label_click: true
      expect(page).to_not have_content('Please answer the question')
    end
  end
end
