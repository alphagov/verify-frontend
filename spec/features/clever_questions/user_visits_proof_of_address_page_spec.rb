require 'feature_helper'
require 'api_test_helper'

describe 'When user visits select proof of address page' do
  before(:each) do
    set_session_and_ab_session_cookies!('clever_questions_v2' => 'clever_questions_v2_variant')
  end

  context 'with javascript enabled', js: true do
    it 'redirects to select phone page when all questions are answered' do
      stub_api_idp_list_for_loa
      stub_transactions_list
      visit '/select-proof-of-address'
      choose 'select_proof_of_address_form_uk_bank_account_details_true', allow_label_click: true
      choose 'select_proof_of_address_form_debit_card_false', allow_label_click: true
      choose 'select_proof_of_address_form_credit_card_false', allow_label_click: true
      click_button 'Continue'

      expect(page).to have_current_path(select_phone_path)
    end

    it 'the page shows errors when no options filled in' do
      visit '/select-proof-of-address'
      click_button 'Continue'
      expect(page).to have_css '#validation-error-message-js', text: 'Please answer all the questions'
    end

    it 'the page shows errors when not all options filled' do
      visit '/select-proof-of-address'
      choose 'select_proof_of_address_form_uk_bank_account_details_true', allow_label_click: true
      click_button 'Continue'
      expect(page).to have_css '#validation-error-message-js', text: 'Please answer all the questions'
    end
  end

  context 'with javascript disabled' do
    it 'and no options filled in on proof of address page, shows errors' do
      visit '/select-proof-of-address'
      click_button 'Continue'
      expect(page).to have_css '.validation-message', text: 'Please answer all the questions'
      expect(page).to have_css '.form-group-error'
    end

    it 'and not all options filled in on proof of address page, shows errors' do
      visit '/select-proof-of-address'
      choose 'select_proof_of_address_form_uk_bank_account_details_true'
      click_button 'Continue'
      expect(page).to have_css '.validation-message', text: 'Please answer all the questions'
      expect(page).to have_css '.form-group-error'
    end
  end
end
