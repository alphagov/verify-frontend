require 'feature_helper'
require 'api_test_helper'

RSpec.feature 'When users visits other documents page' do
  before(:each) do
    set_session_and_ab_session_cookies!('clever_questions_v2' => 'clever_questions_v2_variant')
  end

  it 'redirects user to proof of address page if selects yes' do
    visit '/other-identity-documents'
    choose 'other_identity_documents_form_non_uk_id_document_true', allow_label_click: true
    click_button 'Continue'

    expect(page).to have_current_path(select_proof_of_address_path, only_path: true)
  end

  it 'redirects user to proof of address page if selects no' do
    visit '/other-identity-documents'
    choose 'other_identity_documents_form_non_uk_id_document_false', allow_label_click: true
    click_button 'Continue'

    expect(page).to have_current_path(select_proof_of_address_path, only_path: true)
  end

  it 'shows an error message when no selections are made' do
    visit '/other-identity-documents'
    click_button 'Continue'

    expect(page).to have_css '.validation-message', text: 'Please select the documents you have'
    expect(page).to have_css '.form-group-error'
  end

  it 'should show a feedback link' do
    visit '/other-identity-documents'

    expect_feedback_source_to_be(page, 'OTHER_IDENTITY_DOCUMENTS_PAGE', '/other-identity-documents')
  end
end
