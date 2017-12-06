require 'rails_helper'
require 'controller_helper'
require 'spec_helper'
require 'api_test_helper'
require 'piwik_test_helper'
require 'models/display/viewable_identity_provider'

describe CleverQuestions::SelectPhoneController do
  valid_phone_evidence = { mobile_phone: 'true' }.freeze

  before(:each) do
    set_session_and_cookies_with_loa('LEVEL_2')
    session[:selected_answers] = {
      'documents' => { driving_licence: true, passport: true },
      'device_type' => { device_type_other: true }
    }
    stub_piwik_request({ 'action_name' => 'Phone Next' }, {}, 'LEVEL_2')
  end

  context 'when form is valid' do
    subject { post :select_phone, params: { locale: 'en', select_phone_form: valid_phone_evidence } }

    it 'redirects to choose certified company page when eligible IDPs exist' do
      expect(subject).to redirect_to('/confirming-it-is-you')
    end

    it 'captures form values in session cookie' do
      expect(subject).to redirect_to('/confirming-it-is-you')
      expect(session[:selected_answers]['phone']).to eq(mobile_phone: true)
    end

    it 'append form values in session cookie if some already exist' do
      stub_api_idp_list_for_loa
      session[:selected_answers] = {
          'device_type' => { device_type_other: true },
          'documents' => { driving_licence: true, passport: true },
          'phone' => { smart_phone: true }
      }
      expect(subject).to redirect_to('/confirming-it-is-you')
      expect(session[:selected_answers]['phone']).to eq(mobile_phone: true, smart_phone: true)
    end

    it 'overwrites stored values in session cookie if they exist' do
      stub_api_idp_list_for_loa
      session[:selected_answers] = {
          'device_type' => { device_type_other: true },
          'documents' => { driving_licence: true, passport: true },
          'phone' => { mobile_phone: false, smart_phone: true }
      }
      expect(subject).to redirect_to('/confirming-it-is-you')
      expect(session[:selected_answers]['phone']).to eq(mobile_phone: true, smart_phone: true)
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
      expect(ANALYTICS_REPORTER).not_to receive(:report_action)
    end
  end
end
