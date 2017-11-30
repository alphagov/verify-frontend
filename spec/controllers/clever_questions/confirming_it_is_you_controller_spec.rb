require 'rails_helper'
require 'controller_helper'
require 'spec_helper'
require 'api_test_helper'
require 'piwik_test_helper'

describe CleverQuestions::ConfirmingItIsYouController do
  yes_smart_phone_evidence = { smart_phone: 'true' }.freeze
  no_smart_phone_evidence = { smart_phone: 'false' }.freeze

  before(:each) do
    set_session_and_cookies_with_loa('LEVEL_2')
    session[:selected_answers] = { 'documents' => { driving_licence: true, passport: true } }
    stub_piwik_request('action_name' => 'Phone Next')
  end

  context 'when form is submitted with smart_phone answer ticked' do
    subject { post :select_answer, params: { locale: 'en', confirming_it_is_you_form: yes_smart_phone_evidence } }

    it 'redirects to the proof of address page' do
      expect(subject).to redirect_to('/select-proof-of-address')
    end

    it 'captures form values in session cookie' do
      expect(subject).to redirect_to('/select-proof-of-address')
      expect(session[:selected_answers]['phone']).to eq(smart_phone: true)
    end

    it 'does not overwrite evidence for phone already stored in session cookie' do
      session[:selected_answers] = { 'documents' => { driving_licence: true, passport: true }, 'phone' => { mobile_phone: true } }
      expect(subject).to redirect_to('/select-proof-of-address')
      expect(session[:selected_answers]['phone']).to eq(mobile_phone: true, smart_phone: true)
    end
  end

  context 'when form is submitted without anything' do
    subject { post :select_answer, params: { locale: 'en', confirming_it_is_you_form: no_smart_phone_evidence } }

    it 'redirects to the proof of address page' do
      expect(subject).to redirect_to('/select-proof-of-address')
    end

    it 'smart_phone evidence defaults to false' do
      stub_api_idp_list
      expect(subject).to redirect_to('/select-proof-of-address')
      expect(session[:selected_answers]['phone']).to eq(smart_phone: false)
    end
  end
end
