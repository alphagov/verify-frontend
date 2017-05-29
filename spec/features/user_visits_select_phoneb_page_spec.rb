require 'feature_helper'
require 'api_test_helper'
require 'uri'

RSpec.describe 'When the user visits the select phone page' do
  let(:selected_answers) { { documents: { passport: true, driving_licence: true } } }
  let(:given_a_session_with_document_evidence) {
    page.set_rack_session(
      selected_idp: { entity_id: 'http://idcorp.com', simple_id: 'stub-idp-one' },
      selected_idp_was_recommended: true,
      selected_answers: selected_answers,
    )
  }

  before(:each) do
    set_session_and_ab_session_cookies!
  end

  context 'with javascript disabled' do
    it 'redirects to the idp picker page when user has a phone' do
      set_stub_federation_no_docs_in_session
      visit '/select-phone'

      choose 'select_phone_form_mobile_phone_true', allow_label_click: true
      choose 'select_phone_form_smart_phone_true', allow_label_click: true
      choose 'select_phone_form_landline_false', allow_label_click: true
      click_button 'Continue'

      expect(page).to have_current_path(choose_a_certified_company_path, only_path: true)
      expect(page.get_rack_session['selected_answers']).to eql('phone' => { 'mobile_phone' => true, 'smart_phone' => true, 'landline' => false })
    end

    it 'allows you to overwrite the values of your selected evidence' do
      page.set_rack_session(transaction_simple_id: 'test-rp')
      given_a_session_with_document_evidence

      visit '/select-phone'

      choose 'select_phone_form_mobile_phone_true', allow_label_click: true
      choose 'select_phone_form_smart_phone_true', allow_label_click: true
      click_button 'Continue'

      visit '/select-phone'
      choose 'select_phone_form_mobile_phone_false', allow_label_click: true
      choose 'select_phone_form_landline_false', allow_label_click: true
      click_button 'Continue'

      expect(page).to have_current_path(no_mobile_phone_path)
      expect(page.get_rack_session['selected_answers']).to eql(
        'phone' => { 'mobile_phone' => false, 'landline' => false },
        'documents' => { 'passport' => true, 'driving_licence' => true })
    end

    it 'shows an error message when no selections are made' do
      visit '/select-phone'
      click_button 'Continue'

      expect(page).to have_css '.validation-message', text: 'Please answer all the questions'
      expect(page).to have_css '.form-group-error'
    end
  end

  context 'with javascript enabled', js: true do
    it 'redirects to the idp picker page when user has a phone' do
      given_a_session_with_document_evidence

      visit '/select-phone'

      choose 'select_phone_form_mobile_phone_true', allow_label_click: true
      choose 'select_phone_form_smart_phone_true', allow_label_click: true
      click_button 'Continue'

      expect(page).to have_current_path(choose_a_certified_company_path)
      expect(page.get_rack_session['selected_answers']).to eql(
        'phone' => { 'mobile_phone' => true, 'smart_phone' => true },
        'documents' => { 'passport' => true, 'driving_licence' => true })
    end

    it 'should display a validation message when user does not answer mobile phone question' do
      visit '/select-phone'

      click_button 'Continue'

      expect(page).to have_current_path(select_phone_path)
      expect(page).to have_css '#validation-error-message-js', text: 'Please answer all the questions'
    end

    it 'redirects to the no mobile phone page when no idps can verify' do
      visit '/select-phone'

      choose 'select_phone_form_mobile_phone_false', allow_label_click: true
      choose 'select_phone_form_landline_false', allow_label_click: true
      click_button 'Continue'

      expect(page).to have_current_path(no_mobile_phone_path)
      expect(page.get_rack_session['selected_answers']).to eql('phone' => { 'mobile_phone' => false, 'landline' => false })
    end
  end

  it 'includes the appropriate feedback source' do
    visit '/select-phone'

    expect_feedback_source_to_be(page, 'SELECT_PHONE_PAGE', '/select-phone')
  end

  it 'displays the page in Welsh' do
    visit 'dewis-ffon'
    expect(page).to have_title 'Oes gennych ffôn symudol neu lechen?'
    expect(page).to have_css 'html[lang=cy]'
  end

  it 'reports to Piwik when form is valid' do
    stub_request(:get, INTERNAL_PIWIK.url).with(query: hash_including({}))
    piwik_request = { 'action_name' => 'Phone Next' }

    page.set_rack_session(transaction_simple_id: 'test-rp')
    visit '/select-phone'

    choose 'select_phone_form_mobile_phone_true', allow_label_click: true
    choose 'select_phone_form_smart_phone_true', allow_label_click: true
    click_button 'Continue'

    expect(a_request(:get, INTERNAL_PIWIK.url).with(query: hash_including(piwik_request))).to have_been_made.once
  end

  it 'does not report to Piwik when form is invalid' do
    stub_request(:get, INTERNAL_PIWIK.url).with(query: hash_including({}))
    piwik_request = { 'action_name' => 'Phone Next' }
    visit '/select-phone'

    click_button 'Continue'

    expect(a_request(:get, INTERNAL_PIWIK.url).with(query: hash_including(piwik_request))).to_not have_been_made
  end
end
