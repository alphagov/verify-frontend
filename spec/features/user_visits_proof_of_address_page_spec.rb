require 'feature_helper'
require 'api_test_helper'

describe 'User journeys with proof of address AB test cookie' do
  context 'with control cookie' do
    before(:each) do
      set_session_and_ab_session_cookies!('proof_of_address' => 'proof_of_address_control')
    end

    it 'at select documents valid GB licence or UK passport user goes to select phone' do
      visit '/select-documents'
      choose 'select_documents_form_any_driving_licence_true'
      check 'select_documents_form_driving_licence'
      choose 'select_documents_form_passport_true'
      click_button 'Continue'
      expect(page).to have_current_path(select_phone_path)
    end

    it 'at non uk id page the next page goes to select phone' do
      visit '/other-identity-documents'
      choose 'other_identity_documents_form_non_uk_id_document_true'
      click_button 'Continue'
      expect(page).to have_current_path(select_phone_path)
    end
  end

  context 'with variant cookie' do
    before(:each) do
      set_session_and_ab_session_cookies!('proof_of_address' => 'proof_of_address_variant')
    end

    it 'at select documents with passport and driving licence goes to proof of address' do
      visit '/select-documents'
      choose 'select_documents_form_any_driving_licence_true'
      check 'select_documents_form_driving_licence'
      choose 'select_documents_form_passport_true'
      click_button 'Continue'
      expect(page).to have_current_path(select_proof_of_address_path)
    end

    it 'at uk id page the next page goes to proof of address' do
      visit '/other-identity-documents'
      choose 'other_identity_documents_form_non_uk_id_document_true'
      click_button 'Continue'
      expect(page).to have_current_path(select_proof_of_address_path)
    end

    it 'at proof of address with no documents goes to no IDPs available page and reports to Piwick' do
      stub_request(:get, INTERNAL_PIWIK.url).with(query: hash_including({}))
      piwik_request = { 'action_name' => 'Proof of Address Next' }
      stub_api_idp_list
      visit '/select-proof-of-address'

      choose 'select_proof_of_address_form_uk_bank_account_details_false'
      choose 'select_proof_of_address_form_debit_card_false'
      choose 'select_proof_of_address_form_credit_card_false'
      click_button 'Continue'

      expect(page).to have_current_path(no_idps_available_path)
      expect(a_request(:get, INTERNAL_PIWIK.url).with(query: hash_including(piwik_request))).to have_been_made.once
    end

    it 'at proof of address with passport and driving licence goes to select phone page' do
      stub_api_idp_list
      page.set_rack_session(selected_answers: { documents: { passport: true, driving_licence: true } })
      visit '/select-proof-of-address'
      choose 'select_proof_of_address_form_uk_bank_account_details_false'
      choose 'select_proof_of_address_form_debit_card_false'
      choose 'select_proof_of_address_form_credit_card_false'
      click_button 'Continue'
      expect(page).to have_current_path(select_phone_path)
    end

    it 'at proof of address with bank account goes to select phone page and updates selected answers' do
      stub_api_idp_list
      visit '/select-proof-of-address'
      choose 'select_proof_of_address_form_uk_bank_account_details_true'
      choose 'select_proof_of_address_form_debit_card_false'
      choose 'select_proof_of_address_form_credit_card_false'
      click_button 'Continue'
      expect(page).to have_current_path(select_phone_path)
      expect(page.get_rack_session['selected_answers']).to eql('address_proof' => { 'uk_bank_account_details' => true, 'debit_card' => false, 'credit_card' => false })
    end
  end
end

describe 'When user visits select proof of address page' do
  before(:each) do
    set_session_and_ab_session_cookies!('proof_of_address' => 'proof_of_address_variant')
  end
  context 'with javascript enabled', js: true do
    it 'with javascript on and no options filled in on proof of address page, shows errors' do
      visit '/select-proof-of-address'
      click_button 'Continue'
      expect(page).to have_current_path(select_proof_of_address_path)
      expect(page).to have_css '#validation-error-message-js', text: 'Please answer all the questions'
    end

    it 'with javascript on and not all options filled in on proof of address page, shows errors' do
      visit '/select-proof-of-address'
      choose 'select_proof_of_address_form_uk_bank_account_details_true', allow_label_click: true
      click_button 'Continue'
      expect(page).to have_current_path(select_proof_of_address_path)
      expect(page).to have_css '#validation-error-message-js', text: 'Please answer all the questions'
    end
  end

  context 'with javascript disabled' do
    it 'and no options filled in on proof of address page, shows errors' do
      visit '/select-proof-of-address'
      click_button 'Continue'
      expect(page).to have_current_path(select_proof_of_address_path)
      expect(page).to have_css '.validation-message', text: 'Please answer all the questions'
      expect(page).to have_css '.form-group-error'
    end

    it 'and not all options filled in on proof of address page, shows errors' do
      visit '/select-proof-of-address'
      choose 'select_proof_of_address_form_uk_bank_account_details_true'
      click_button 'Continue'
      expect(page).to have_current_path(select_proof_of_address_path)
      expect(page).to have_css '.validation-message', text: 'Please answer all the questions'
      expect(page).to have_css '.form-group-error'
    end

    it 'updates evidence when user clicks no documents link' do
      stub_api_idp_list
      visit '/select-proof-of-address'
      click_link 'I don\'t have any of these documents'
      expect(page).to have_current_path(no_idps_available_path)
      expect(page.get_rack_session['selected_answers']).to eql('address_proof' => { 'uk_bank_account_details' => false, 'debit_card' => false, 'credit_card' => false })
    end

    it 'goes to mobile phone page when user clicks link and has uk documents' do
      stub_api_idp_list
      page.set_rack_session(selected_answers: { documents: { passport: true, driving_licence: true } })
      visit '/select-proof-of-address'
      click_link 'I don\'t have any of these documents'
      expect(page).to have_current_path(select_phone_path)
    end
  end
end
