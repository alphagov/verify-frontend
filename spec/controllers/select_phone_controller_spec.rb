require 'rails_helper'
require 'controller_helper'
require 'spec_helper'
require 'api_test_helper'
require 'piwik_test_helper'
require 'models/display/viewable_identity_provider'

describe SelectPhoneController do
  valid_phone_evidence = { mobile_phone: 'true', smart_phone: 'true', landline: 'true' }.freeze

  before(:each) do
    set_session_and_cookies_with_loa('LEVEL_1')
    session[:selected_answers] = { 'documents' => { driving_licence: true, passport: true } }
  end

  context 'when form is valid' do
    subject { post :select_phone, params: { locale: 'en', select_phone_form: valid_phone_evidence } }

    before :each do
      stub_piwik_request('action_name' => 'Phone Next')
    end

    it 'redirects to choose certified company page when eligible IDPs exist' do
      stub_api_idp_list([{ 'simpleId' => 'stub-idp-one',
                           'entityId' => 'http://idcorp.com',
                           'levelsOfAssurance' => %w(LEVEL_2) }])

      expect(subject).to redirect_to('/choose-a-certified-company')
    end

    it 'redirects to no mobile phone page when no eligible IDPs' do
      stub_api_idp_list([{ 'simpleId' => 'stub-idp-four',
                           'entityId' => 'http://idcorp.com',
                           'levelsOfAssurance' => %w(LEVEL_2) }])

      expect(subject).to redirect_to('/no-mobile-phone')
    end

    it 'captures form values in session cookie' do
      stub_api_idp_list
      expect(subject).to redirect_to('/choose-a-certified-company')
      expect(session[:selected_answers]['phone']).to eq(mobile_phone: true, smart_phone: true, landline: true)
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
