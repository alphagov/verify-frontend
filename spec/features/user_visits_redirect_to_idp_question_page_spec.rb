require 'feature_helper'
require 'api_test_helper'
require 'piwik_test_helper'
require 'i18n'

RSpec.describe 'When the user visits the redirect to IDP question page' do
  let(:selected_answers) {
    { 'phone' => { 'mobile_phone' => true, 'smart_phone' => true },
      'documents' => { 'passport' => true }
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

  before(:each) do
    set_session_and_session_cookies!
    given_an_idp_with_interstitial_question_needed
    visit '/redirect-to-idp-question'
  end

  it 'displays interstitial question' do
    expect(page).to have_content('I have a question for you in English')
  end

  it 'displays interstitial question in Welsh' do
    visit '/ailgyfeirio-i-gwestiwn-idp'

    expect(page).to have_content('I have a question for you in Welsh')
    expect(page).to have_css 'html[lang=cy]'
  end

  it 'goes to "redirect-to-idp-warning" page if the user answers the question and javascript is enabled', js: true do
    stub_session_idp_authn_request(originating_ip, idp_location, false)

    choose 'interstitial_question_form_interstitial_question_result_true', allow_label_click: true

    expected_answers = selected_answers.update('interstitial' => { 'interstitial_yes' => true })

    click_button 'Continue'

    expect(page).to have_current_path(redirect_to_idp_warning_path)
    expect(page.get_rack_session['selected_answers']).to eql(expected_answers)
  end

  it 'goes to "idp-wont-work-for-you" page if the user answers no to the interstitial question and javascript is enabled', js: true do
    choose 'interstitial_question_form_interstitial_question_result_false', allow_label_click: true
    click_button 'Continue'
    expect(page).to have_title(I18n.t('hub.idp_wont_work_for_you_one_doc.title'))
  end

  it 'displays an error message when user does not answer the question when javascript is turned off' do
    click_button 'Continue'

    expect(page).to have_current_path(redirect_to_idp_question_submit_path)
    expect(page).to have_content('Please answer the question')
  end

  context 'when the form is invalid', js: true do
    it 'should display validation message if no selection is made' do
      click_button 'Continue'
      expect(page).to have_content('Please answer the question')
    end

    it 'should remove validation message once selection is made' do
      click_button 'Continue'
      expect(page).to have_content('Please answer the question')
      choose 'interstitial_question_form_interstitial_question_result_false', allow_label_click: true
      expect(page).to_not have_content('Please answer the question')
    end
  end
end
