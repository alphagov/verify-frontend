require 'feature_helper'
require 'api_test_helper'

RSpec.feature 'When users visits other documents page' do
  before(:each) do
    set_session_and_ab_session_cookies!('short_questions' => 'short_questions_variant')
  end

  it 'redirects user to choose-a-certified-company page if selects yes and has smartphone' do
    stub_api_idp_list_for_loa

    visit '/other-identity-documents'
    choose 'other_identity_documents_variant_form_non_uk_id_document_true', allow_label_click: true
    choose 'other_identity_documents_variant_form_smart_phone_true', allow_label_click: true
    click_button t('navigation.continue')

    expect(page).to have_current_path(choose_a_certified_company_path, only_path: true)
  end

  it 'redirects user to choose-a-certified-company page if selects yes and does not have smartphone' do
    stub_api_idp_list_for_loa

    visit '/other-identity-documents'
    choose 'other_identity_documents_variant_form_non_uk_id_document_true', allow_label_click: true
    choose 'other_identity_documents_variant_form_smart_phone_false', allow_label_click: true
    click_button t('navigation.continue')

    expect(page).to have_current_path(choose_a_certified_company_path, only_path: true)
  end

  it 'redirects user to choose-a-certified-company page if selects no' do
    stub_api_idp_list_for_loa

    visit '/other-identity-documents'
    choose 'other_identity_documents_variant_form_non_uk_id_document_false', allow_label_click: true
    click_button t('navigation.continue')

    expect(page).to have_current_path(choose_a_certified_company_path, only_path: true)
  end

  it 'should show a feedback link' do
    visit '/other-identity-documents'

    expect_feedback_source_to_be(page, 'OTHER_IDENTITY_DOCUMENTS_PAGE', '/other-identity-documents')
  end
end
