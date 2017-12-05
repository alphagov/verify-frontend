require 'feature_helper'
require 'api_test_helper'
require 'uri'

RSpec.describe 'When the user visits the confirming it is you page' do
  let(:selected_answers) { { documents: { passport: true, driving_licence: true } } }
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
    it 'redirects to the select phone page on selection of no smartphone and submit' do
      stub_api_no_docs_idps
      visit '/confirming-it-is-you'

      check 'confirming_it_is_you_form_no_smart_phone', allow_label_click: true
      click_button 'Continue'

      expect(page).to have_current_path(select_phone_path, only_path: true)
      expect(page.get_rack_session['selected_answers']).to eql('phone' => { 'smart_phone' => false })
    end

    it 'allows you to overwrite the values of your selected evidence' do
      page.set_rack_session(transaction_simple_id: 'test-rp')
      given_a_session_with_document_evidence

      visit '/confirming-it-is-you'

      check 'confirming_it_is_you_form_no_smart_phone', allow_label_click: true
      click_button 'Continue'

      visit '/confirming-it-is-you'
      click_button 'Continue'

      expect(page).to have_current_path(select_phone_path)
      expect(page.get_rack_session['selected_answers']).to eql(
        'phone' => { 'smart_phone' => true },
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
