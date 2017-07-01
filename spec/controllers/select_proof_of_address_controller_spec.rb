require 'rails_helper'
require 'controller_helper'
require 'api_test_helper'

describe SelectProofOfAddressController do
  before(:each) do
    set_session_and_cookies_with_loa('LEVEL_1')
  end

  context 'when GET is called' do
    subject { get :index, params: { locale: 'en' } }

    it 'proof of address template is rendered' do
      subject

      expect(subject).to render_template(:select_proof_of_address)
    end
  end

  context 'when POST is called' do
    subject { post :select_proof, params: { locale: 'en', select_proof_of_address_form: { bank_account: true, debit_card: true, credit_card: false } } }

    it 'params submitted are stored in session' do
      subject

      expect(session[:selected_answers]['address_proof']).to eq(bank_account: true, debit_card: true, credit_card: false)
    end
  end
end
