require 'rails_helper'
require 'controller_helper'
require 'spec_helper'
require 'api_test_helper'
require 'piwik_test_helper'
require 'models/display/viewable_identity_provider'

describe SelectPhoneVariantController do
  valid_phone_evidence = { mobile_phone: 'true', smart_phone: 'true', landline: 'true' }.freeze

  before(:each) do
    set_session_and_cookies_with_loa('LEVEL_1')
    session[:selected_answers] = { 'documents' => { driving_licence: true, passport: true } }
  end

  context 'when form is valid' do
    before :each do
      stub_piwik_request('action_name' => 'Phone Next')
    end

    context 'redirects to' do
      subject { post :select_phone, params: { locale: 'en', select_phone_form: valid_phone_evidence } }

      it 'choose certified company page when eligible IDPs exist' do
        stub_api_idp_list([{ 'simpleId' => 'stub-idp-one',
                             'entityId' => 'http://idcorp.com',
                             'levelsOfAssurance' => %w(LEVEL_2) }])

        expect(subject).to redirect_to('/choose-a-certified-company')
      end

      it 'no mobile phone page when no eligible IDPs' do
        stub_api_idp_list([{ 'simpleId' => 'stub-idp-four',
                             'entityId' => 'http://idcorp.com',
                             'levelsOfAssurance' => %w(LEVEL_2) }])

        expect(subject).to redirect_to('/no-mobile-phone')
      end
    end

    context 'capture session cookie for' do
      before :each do
        stub_api_idp_list
      end

      it 'form values' do
        post :select_phone, params: { locale: 'en', select_phone_form: valid_phone_evidence }

        expect(subject).to redirect_to('/choose-a-certified-company')
        expect(session[:selected_answers]['phone']).to eq(mobile_phone: true, smart_phone: true, landline: true)
      end

      it 'reluctant mobile app installation with a value of true when smart phone reluctant yes is chosen' do
        post :select_phone, params: { locale: 'en',
                                      select_phone_form: { smart_phone: 'reluctant_yes' } }

        expect(session[:reluctant_mob_installation]).to eq(true)
      end

      it 'reluctant mobile app installation with a value of false when smart phone yes is chosen' do
        post :select_phone, params: { locale: 'en',
                                      select_phone_form: { smart_phone: true } }

        expect(session[:reluctant_mob_installation]).to eq(false)
      end

      it 'reluctant mobile app installation with a value of false when smart phone no is chosen' do
        post :select_phone, params: { locale: 'en',
                                      select_phone_form: { smart_phone: false } }

        expect(session[:reluctant_mob_installation]).to eq(false)
      end
    end
  end

  context 'when form is invalid' do
    subject { post :select_phone, params: { locale: 'en' } }

    it 'renders itself' do
      expect(subject).to render_template(:index)
    end

    it 'does not capture form values in session cookie' do
      expect(session[:selected_answers]['phone']).to eq(nil)
    end

    it 'does not report to Piwik' do
      expect(ANALYTICS_REPORTER).not_to receive(:report)
    end
  end
end
