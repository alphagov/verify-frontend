require 'feature_helper'
require 'api_test_helper'

RSpec.feature 'When users visits other documents page' do
  context 'happy path' do
    before(:each) do
      set_session_and_session_cookies!
      visit '/other-identity-documents'
    end

    it 'should show other documents content' do
      expect(page).to have_content('Other identity documents')
    end

    it 'should show other documents content in Welsh' do
      visit '/dogfennau-hunaniaeth-eraill'
      expect(page).to have_content('Dogfennau hunaniaeth eraill')
    end

    it 'should go to select phone path and set selected answers when user has other identity documents' do
      choose 'other_identity_documents_form_non_uk_id_document_true'
      click_button 'Continue'
      expect(page).to have_current_path(select_phone_path)
      expect(page.get_rack_session['selected_answers']).to eql('documents' => { 'non_uk_id_document' => true })
    end

    it 'should go to select phone path and set selected answers when user does not have other identity documents' do
      choose 'other_identity_documents_form_non_uk_id_document_false'
      click_button 'Continue'
      expect(page).to have_current_path(select_phone_path)
      expect(page.get_rack_session['selected_answers']).to eql('documents' => { 'non_uk_id_document' => false })
    end

    it 'should show a feedback link' do
      expect_feedback_source_to_be(page, 'OTHER_IDENTITY_DOCUMENTS_PAGE', '/other-identity-documents')
    end
  end

  context 'user has pressed back key and old select document answers have been retained when visiting other id page' do
    before(:each) do
      set_session_and_session_cookies!
    end

    let(:session_with_stale_select_documents_answers) {
      {
          selected_answers: { documents: { passport: true, driving_licence: true, ni_driving_licence: false } }
      }
    }

    it 'will only contain has non-uk id document and will ignore any stale form values for passport and licence' do
      set_session!(session_with_stale_select_documents_answers)
      visit '/other-identity-documents'
      choose 'other_identity_documents_form_non_uk_id_document_true'
      click_button 'Continue'
      only_has_non_uk_doc = { 'documents' => { 'non_uk_id_document' => true } }
      expect(page.get_rack_session['selected_answers']).to eql(only_has_non_uk_doc)
    end
  end
end
