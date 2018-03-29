require 'feature_helper'
require 'api_test_helper'

RSpec.feature 'When user visits document selection page' do
  before(:each) do
    set_session_and_ab_session_cookies!('short_questions_v2' => 'short_questions_v2_variant')
    visit '/select-documents'
  end

  it 'includes the appropriate feedback source' do
    expect_feedback_source_to_be(page, 'SELECT_DOCUMENTS_PAGE', '/select-documents')
  end

  it 'should have a header about Setting up an online identity as per the wireframe' do
    expect(page).to have_content('Setting up an online identity')
  end

  it 'should have a header about photo identity documents in English for the text if user selects Welsh' do
    visit '/dewis-dogfennau'
    expect(page).to have_content('Setting up an online identity')
  end

  it 'should go to choose-a-certified-company when user has a valid GB licence and UK passport' do
    stub_api_idp_list_for_loa
    choose 'select_documents_form_any_driving_licence_true'
    choose 'select_documents_form_driving_licence_great_britain'
    choose 'select_documents_form_passport_true'
    click_button t('navigation.continue')
    expect(page).to have_current_path(choose_a_certified_company_path)
    expect(page.get_rack_session['selected_answers']).to eql(
      'device_type' => { 'device_type_other' => true },
      'documents' => { 'passport' => true, 'driving_licence' => true, 'ni_driving_licence' => false }
    )
  end

  it 'should go to choose-a-certified-company when user has only a valid GB licence' do
    stub_api_idp_list_for_loa
    choose 'select_documents_form_any_driving_licence_true'
    choose 'select_documents_form_driving_licence_great_britain'
    choose 'select_documents_form_passport_false'
    click_button t('navigation.continue')
    expect(page).to have_current_path(choose_a_certified_company_path)
    expect(page.get_rack_session['selected_answers']).to eql(
      'device_type' => { 'device_type_other' => true },
      'documents' => { 'passport' => false, 'driving_licence' => true, 'ni_driving_licence' => false }
   )
  end

  it 'should go to choose-a-certified-company when user has only a valid NI licence' do
    stub_api_idp_list_for_loa
    choose 'select_documents_form_any_driving_licence_true'
    choose 'select_documents_form_driving_licence_northern_ireland'
    choose 'select_documents_form_passport_false'
    click_button t('navigation.continue')
    expect(page).to have_current_path(choose_a_certified_company_path)
    expect(page.get_rack_session['selected_answers']).to eql(
      'device_type' => { 'device_type_other' => true },
      'documents' => { 'passport' => false, 'driving_licence' => false, 'ni_driving_licence' => true }
   )
  end

  it 'should go to choose-a-certified-company when user has only a valid UK passport' do
    stub_api_idp_list_for_loa
    choose 'select_documents_form_any_driving_licence_false'
    choose 'select_documents_form_passport_true'
    click_button t('navigation.continue')
    expect(page).to have_current_path(choose_a_certified_company_path)
    expect(page.get_rack_session['selected_answers']).to eql(
      'device_type' => { 'device_type_other' => true },
      'documents' => { 'passport' => true, 'driving_licence' => false, 'ni_driving_licence' => false }
   )
  end

  context 'user does not have UK driving license or valid passport' do
    it 'should go to other documents page if user does not have UK driving licence or UK passport' do
      choose 'select_documents_form_any_driving_licence_false'
      choose 'select_documents_form_passport_false'
      click_button t('navigation.continue')
      expect(page).to have_current_path(other_identity_documents_path)
      expect(page.get_rack_session['selected_answers']).to eql(
        'device_type' => { 'device_type_other' => true },
        'documents' => { 'passport' => false, 'driving_licence' => false, 'ni_driving_licence' => false }
      )
    end
  end
end
