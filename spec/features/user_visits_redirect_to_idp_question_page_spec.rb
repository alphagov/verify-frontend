require 'feature_helper'
require 'api_test_helper'
require 'piwik_test_helper'
require 'i18n'

RSpec.describe 'When the user visits the redirect to IDP question page' do
  let(:selected_answers) {
    { phone: { mobile_phone: true, smart_phone: true },
      documents: { passport: true }
    }
  }
  let(:originating_ip) { '<PRINCIPAL IP ADDRESS COULD NOT BE DETERMINED>' }
  let(:idp_location) { '/test-idp-request-endpoint' }
  let(:given_an_idp_with_interstitial_question_needed) {
    page.set_rack_session(
      selected_idp: { entity_id: 'stub-idp-one-doc-question', simple_id: 'stub-idp-one-doc-question' },
      selected_idp_was_recommended: true,
      selected_answers: selected_answers,
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

  it 'displays interstitial question' do
    expect(page).to have_content('Verifying with FancyPants')
    expect(page).to have_content('I have a question for you in English')
  end

  it 'displays interstitial question in Welsh' do
    visit '/ailgyfeirio-i-gwestiwn-idp'

    expect(page).to have_content('Dilysu gyda Welsh FancyPants')
    expect(page).to have_content('I have a question for you in Welsh')
    expect(page).to have_css 'html[lang=cy]'
  end

  it 'goes to "redirect-to-idp" page if the user answers the question' do
    select_idp_stub_request
    stub_session_idp_authn_request(originating_ip, idp_location, false)

    choose 'interstitial_question_form_extra_info_false', allow_label_click: true

    expected_answers = selected_answers.update(interstitial: { interstitial_no: true })

    piwik_registration_virtual_page = stub_piwik_idp_registration('FancyPants', selected_answers: expected_answers, recommended: true)

    click_button 'Continue to FancyPants'

    expect(page).to have_current_path(redirect_to_idp_path)
    expect(piwik_registration_virtual_page).to have_been_made.once
    expect(select_idp_stub_request).to have_been_made.once
    expect(cookie_value('verify-front-journey-hint')).to_not be_nil
  end

  it 'goes to "redirect-to-idp" page if the user answers the question and javascript is enabled', js: true do
    select_idp_stub_request
    stub_session_idp_authn_request(originating_ip, idp_location, false)

    choose 'interstitial_question_form_extra_info_true', allow_label_click: true

    expected_answers = selected_answers.update(interstitial: { interstitial_yes: true })

    piwik_registration_virtual_page = stub_piwik_idp_registration('FancyPants', selected_answers: expected_answers, recommended: true)

    click_button 'Continue to FancyPants'

    expect(page).to have_current_path(idp_location)
    expect(piwik_registration_virtual_page).to have_been_made.once
    expect(select_idp_stub_request).to have_been_made.once
    expect(cookie_value('verify-front-journey-hint')).to_not be_nil
  end

  it 'displays an error message when user does not answer the question when javascript is turned off' do
    click_button 'Continue to FancyPants'

    expect(page).to have_current_path(redirect_to_idp_question_submit_path)
    expect(page).to have_content('Please answer the question')
  end

  context 'react appropriately when user fills in form', js: true do
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
