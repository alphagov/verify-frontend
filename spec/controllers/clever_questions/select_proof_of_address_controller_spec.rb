require 'rails_helper'
require 'controller_helper'
require 'api_test_helper'
require 'piwik_test_helper'

describe CleverQuestions::SelectProofOfAddressController do
  before(:each) do
    set_session_and_cookies_with_loa('LEVEL_1')
  end

  it 'proof of address template is rendered' do
    get :index, params: { locale: 'en' }

    expect(subject).to render_template(:select_proof_of_address)
  end

  it 'redirects to confirming it is you page' do
    stub_piwik_request('action_name' => 'Proof of Address Next')

    post :select_proof, params: { locale: 'en', select_proof_of_address_form: { uk_bank_account_details: true, debit_card: true, credit_card: false } }

    expect(subject).to redirect_to('/confirming-it-is-you')
  end

  it 're-renders itself ' do
    post :select_proof, params: { locale: 'en', select_proof_of_address_form: {} }

    expect(subject).to render_template(:select_proof_of_address)
  end
end
