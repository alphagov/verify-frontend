require 'feature_helper'
require 'i18n'

RSpec.describe 'When the user visits the select documents page' do
  before(:each) do
    set_session_cookies!
  end

  it 'displays the page in Welsh' do
    visit '/dewiswch-ddogfennau'
    expect(page).to have_title 'Dewiswch yr holl ddogfennau sydd gennych - GOV.UK Verify - GOV.UK'
    expect(page).to have_css 'html[lang=cy]'
  end

  it 'includes the appropriate feedback source' do
    visit '/select-documents'

    expect_feedback_source_to_be(page, 'SELECT_DOCUMENTS_PAGE')
  end

  it 'redirects to the select phone page when user has a driving licence' do
    stub_federation
    visit '/select-documents'

    choose 'select_documents_form_driving_licence_true'
    click_button 'Continue'

    expect(page).to have_current_path(select_phone_path)
  end

  it 'redirects to the select phone page when no docs checked' do
    stub_federation_no_docs
    visit '/select-documents'

    check I18n.translate('hub.select_documents.question.no_docs')
    click_button 'Continue'

    expect(page).to have_current_path(select_phone_path)
  end

  context 'will validate selections', js: false do
    it 'will show an error message when no selections have been made' do
      visit 'select-documents'

      click_button 'Continue'

      expect(page).to have_content 'Please select the documents you have'
    end
  end

  it 'will redirect user to a unlikely to verify page when no eligible profiles match selected evidence' do
    stub_federation
    visit 'select-documents'
    check 'select_documents_form_no_docs'

    click_button 'Continue'

    expect(page).to have_current_path(unlikely_to_verify_path)
  end
end
