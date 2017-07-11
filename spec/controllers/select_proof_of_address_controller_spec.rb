require 'rails_helper'
require 'controller_helper'
require 'api_test_helper'

describe SelectProofOfAddressController do
  before(:each) do
    set_session_and_cookies_with_loa('LEVEL_1')
  end

  context '#index' do
    subject { get :index, params: { locale: 'en' } }

    it 'proof of address template is rendered' do
      subject

      expect(subject).to render_template(:select_proof_of_address)
    end
  end

  context '#select_proof valid' do
    subject { post :select_proof, params: { locale: 'en', select_proof_of_address_form: { uk_bank_account_details: true, debit_card: true, credit_card: false } } }

    it 'stores session variables' do
      stub_api_idp_list

      subject
      expect(session[:selected_answers]['address_proof']).to eq(uk_bank_account_details: true, debit_card: true, credit_card: false)
    end

    it 'redirects to select phone page' do
      stub_api_idp_list

      expect(subject).to redirect_to('/select-phone')
    end

    it 'redirects to dead-end page' do
      stub_api_idp_list([{ 'simpleId' => 'stub-idp-two', 'entityId' => 'other-entity-id', 'levelsOfAssurance' => %w(LEVEL_1 LEVEL_2) }])

      expect(subject).to redirect_to('/no-idps-available')
    end
  end

  context '#select_proof invalid' do
    subject { post :select_proof, params: { locale: 'en', select_proof_of_address_form: {} } }

    it 're-renders itself ' do
      subject

      expect(subject).to render_template(:select_proof_of_address)
    end
  end
end
