require 'feature_helper'
require 'api_test_helper'

RSpec.feature 'When user visits document selection page' do
  before(:each) do
    set_session_and_session_cookies!
    visit '/select-documents'
  end

  it 'includes the appropriate feedback source' do
    expect_feedback_source_to_be(page, 'SELECT_DOCUMENTS_PAGE', '/select-documents')
  end

  it 'should have a header about photo identity documents' do
    expect(page).to have_content('Your photo identity document')
  end

  it 'should have a header about photo identity documents in Welsh if user selects Welsh' do
    visit '/dewis-dogfennau'
    expect(page).to have_content('Eich dogfennau hunaniaeth gyda llun')
  end

  it 'should go to select phone page when user has a valid GB licence or UK passport' do
    choose 'select_documents_form_any_driving_licence_true'
    check 'select_documents_form_driving_licence'
    choose 'select_documents_form_passport_true'
    click_button 'Continue'
    expect(page).to have_current_path(select_phone_path)
    expect(page.get_rack_session['selected_answers']).to eql('documents' => { 'passport' => true, 'driving_licence' => true, 'ni_driving_licence' => false })
  end

  context 'user does not have UK driving license or valid passport' do
    it 'should go to other documents page if user clicks I dont have either of these documents link' do
      click_link 'I don\'t have either of these documents'
      expect(page).to have_current_path(other_identity_documents_path)
      expect(page.get_rack_session['selected_answers']).to eql('documents' => { 'passport' => false, 'driving_licence' => false, 'ni_driving_licence' => false })
    end

    it 'should go to other documents page if user does not have UK driving licence or UK passport' do
      choose 'select_documents_form_any_driving_licence_false'
      choose 'select_documents_form_passport_false'
      click_button 'Continue'
      expect(page).to have_current_path(other_identity_documents_path)
      expect(page.get_rack_session['selected_answers']).to eql('documents' => { 'passport' => false, 'driving_licence' => false, 'ni_driving_licence' => false })
    end
  end
end
