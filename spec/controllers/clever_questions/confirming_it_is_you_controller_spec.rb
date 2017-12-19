require 'rails_helper'
require 'controller_helper'
require 'spec_helper'
require 'api_test_helper'
require 'piwik_test_helper'

describe CleverQuestions::ConfirmingItIsYouController do
  no_smart_phone_evidence = { no_smart_phone: 'true' }.freeze
  yes_smart_phone_evidence = { no_smart_phone: 'false' }.freeze

  before(:each) do
    set_session_and_cookies_with_loa('LEVEL_2')
    session[:selected_answers] = { 'documents' => { driving_licence: true, passport: true },
                                   'phone' => { mobile_phone: true },
                                   'device_type' => { device_type_other: true } }
    stub_piwik_request('action_name' => 'Smart Phone Next')
  end

  context 'when form is submitted with smart_phone answer ticked' do
    subject { post :select_answer, params: { locale: 'en', confirming_it_is_you_form: no_smart_phone_evidence } }

    it 'redirects to the choose certified company page if IDPs available' do
      stub_api_idp_list_for_loa
      expect(subject).to redirect_to('/choose-a-certified-company')
    end

    it 'redirects to the no mobile phone page if no IDPs available' do
      stub_api_idp_list_for_loa({})
      expect(subject).to redirect_to('/no-mobile-phone')
    end

    it 'captures form values in session cookie' do
      stub_api_idp_list_for_loa
      expect(subject).to redirect_to('/choose-a-certified-company')
      expect(session[:selected_answers]['phone']).to eq(mobile_phone: true, smart_phone: false)
    end

    it 'does not overwrite evidence for phone already stored in session cookie' do
      stub_api_idp_list_for_loa
      session[:selected_answers] = { 'documents' => { driving_licence: true, passport: true },
                                     'phone' => { mobile_phone: true },
                                     'device_type' => { device_type_other: true } }
      expect(subject).to redirect_to('/choose-a-certified-company')
      expect(session[:selected_answers]['phone']).to eq(mobile_phone: true, smart_phone: false)
    end

    it 'keeps mobile phone evidence to false when smart phone is false' do
      stub_api_idp_list_for_loa
      session[:selected_answers] = { 'phone' => { mobile_phone: false } }
      subject
      expect(session[:selected_answers]['phone']).to eq(mobile_phone: false, smart_phone: false)
    end
  end

  context 'when form is submitted without anything' do
    subject { post :select_answer, params: { locale: 'en', confirming_it_is_you_form: yes_smart_phone_evidence } }

    it 'redirects to the choose a certified company page' do
      stub_api_idp_list_for_loa
      expect(subject).to redirect_to('/choose-a-certified-company')
    end

    it 'redirects to the no mobile phone page if no IDPs available' do
      stub_api_idp_list_for_loa({})
      expect(subject).to redirect_to('/no-mobile-phone')
    end

    it 'smart_phone evidence defaults to true' do
      stub_api_idp_list_for_loa
      expect(subject).to redirect_to('/choose-a-certified-company')
      expect(session[:selected_answers]['phone']).to eq(mobile_phone: true, smart_phone: true)
    end

    it 'sets mobile phone evidence to true when it false' do
      stub_api_idp_list_for_loa
      session[:selected_answers] = { 'phone' => { mobile_phone: false } }
      subject
      expect(session[:selected_answers]['phone']).to eq(mobile_phone: true, smart_phone: true)
    end

    it 'sets smart phone evidence to true if no selected answer were previously recorded' do
      stub_api_idp_list_for_loa
      session[:selected_answers] = {}
      subject
      expect(session[:selected_answers]['phone']).to eq(smart_phone: true)
    end
  end
end
