require 'feature_helper'
require 'api_test_helper'

RSpec.feature 'When users visits other documents page' do
  before(:each) do
    set_session_and_session_cookies!
  end

  it 'redirects user to select-phone page if selects yes' do
    visit '/other-identity-documents'
    choose 'other_identity_documents_form_non_uk_id_document_true', allow_label_click: true
    click_button t('navigation.continue')

    expect(page).to have_current_path(select_phone_path, only_path: true)
  end

  it 'redirects user to select-phone page if selects no' do
    visit '/other-identity-documents'
    choose 'other_identity_documents_form_non_uk_id_document_false', allow_label_click: true
    click_button t('navigation.continue')

    expect(page).to have_current_path(select_phone_path, only_path: true)
  end

  it 'should show a feedback link' do
    visit '/other-identity-documents'

    expect_feedback_source_to_be(page, 'OTHER_IDENTITY_DOCUMENTS_PAGE', '/other-identity-documents')
  end
end
