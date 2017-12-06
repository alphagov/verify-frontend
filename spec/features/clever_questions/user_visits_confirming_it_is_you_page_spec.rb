require 'feature_helper'
require 'api_test_helper'
require 'uri'

RSpec.describe 'When the user visits the confirming it is you page' do
  let(:selected_answers) {
    {
      documents: { passport: true, driving_licence: true },
      phone: { mobile_phone: true },
      device_type: { device_type_other: true }
    }
  }
  let(:given_a_session_with_document_evidence) {
    page.set_rack_session(
      selected_idp: { entity_id: 'http://idcorp.com', simple_id: 'stub-idp-one' },
      selected_idp_was_recommended: true,
      selected_answers: selected_answers,
    )
  }

  before(:each) do
    set_session_and_ab_session_cookies!('clever_questions' => 'clever_questions_variant')
    stub_transactions_list
    stub_api_idp_list_for_loa
  end

  context 'with javascript disabled' do
    it 'redirects to the idp picker page when IDPs are available' do
      stub_api_no_docs_idps
      given_a_session_with_document_evidence
      visit '/confirming-it-is-you'

      click_button 'Continue'

      expect(page).to have_current_path(choose_a_certified_company_path, only_path: true)
    end

    it 'set mobile phone evidence to true if user said no mobile phone but said yes to smart phone' do
      stub_api_no_docs_idps
      page.set_rack_session(selected_answers: { phone: { mobile_phone: false } })
      visit '/confirming-it-is-you'

      click_button 'Continue'

      expect(page.get_rack_session['selected_answers']).to eql('phone' => { 'mobile_phone' => true, 'smart_phone' => true },
                                                               'device_type' => { 'device_type_other' => true })
    end

    it 'redirects to the no mobile phone page when there are no IDPs available' do
      visit '/confirming-it-is-you'

      click_button 'Continue'

      expect(page).to have_current_path(no_mobile_phone_path, only_path: true)
      expect(page.get_rack_session['selected_answers']).to eql(
        'device_type' => { 'device_type_other' => true },
        'phone' => { 'smart_phone' => true }
      )
    end

    it 'allows you to overwrite the values of your selected evidence' do
      page.set_rack_session(transaction_simple_id: 'test-rp')
      given_a_session_with_document_evidence

      visit '/confirming-it-is-you'

      check 'confirming_it_is_you_form_no_smart_phone', allow_label_click: true
      click_button 'Continue'

      visit '/confirming-it-is-you'
      click_button 'Continue'

      expect(page).to have_current_path(choose_a_certified_company_path)
      expect(page.get_rack_session['selected_answers']).to eql(
        'device_type' => { 'device_type_other' => true },
        'phone' => { 'mobile_phone' => true, 'smart_phone' => true },
        'documents' => { 'passport' => true, 'driving_licence' => true }
      )
    end
  end

  it 'includes the appropriate feedback source' do
    visit '/confirming-it-is-you'

    expect_feedback_source_to_be(page, 'CONFIRMING_IT_IS_YOU_PAGE', '/confirming-it-is-you')
  end

  it 'displays the page in Welsh' do
    visit '/confirming-it-is-you-cy'
    expect(page).to have_content 'Defnyddiwch'
    expect(page).to have_css 'html[lang=cy]'
  end

  it 'reports to Piwik when form is submitted' do
    stub_request(:get, INTERNAL_PIWIK.url).with(query: hash_including({}))
    piwik_request = { 'action_name' => 'Smart Phone Next' }

    page.set_rack_session(transaction_simple_id: 'test-rp')
    visit '/confirming-it-is-you'

    check 'confirming_it_is_you_form_no_smart_phone', allow_label_click: true
    click_button 'Continue'

    expect(a_request(:get, INTERNAL_PIWIK.url).with(query: hash_including(piwik_request))).to have_been_made.once
  end
end
