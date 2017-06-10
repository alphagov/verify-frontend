require 'rails_helper'
require 'controller_helper'
require 'spec_helper'
require 'models/display/viewable_identity_provider'
require 'api_test_helper'

describe SelectPhoneController do
  VALID_PHONE = { mobile_phone: 'true', smart_phone: 'true', landline: 'true' }.freeze
  INVALID_PHONE = { mobile_phone: 'false', smart_phone: 'true' }.freeze

  let(:piwik_reporter) { double(:Reporter) }
  let(:eligibility_checker) { double(:Checker) }

  before(:each) do
    set_session_and_cookies_with_loa('LEVEL_1')
    stub_const('ANALYTICS_REPORTER', piwik_reporter)
    stub_const('IDP_ELIGIBILITY_CHECKER', eligibility_checker)

    stub_api_idp_list([{ 'simpleId' => 'stub-idp-loa1',
                         'entityId' => 'http://idcorp.com',
                         'levelsOfAssurance' => %w(LEVEL_1 LEVEL_2) },
                       { 'simpleId' => 'stub-idp-loa2',
                         'entityId' => 'http://idcorp.com',
                         'levelsOfAssurance' => ['LEVEL_2'] }])
  end

  context 'Redirects:' do
    context 'when form is valid' do
      subject { post :select_phone, params: { locale: 'en', select_phone_form: VALID_PHONE } }

      before(:each) do
        expect(piwik_reporter).to receive(:report)
      end

      it 'redirects to choose certified company page when eligible IDPs exist' do
        expect(eligibility_checker).to receive(:any?).with([:mobile_phone, :smart_phone, :landline], anything).and_return(true)

        expect(subject).to redirect_to('/choose-a-certified-company')
      end

      it 'redirects to no mobile phone page when no eligible IDPs' do
        expect(eligibility_checker).to receive(:any?).with([:mobile_phone, :smart_phone, :landline], anything).and_return(false)

        expect(subject).to redirect_to('/no-mobile-phone')
      end
    end

    context 'when form is invalid' do
      subject { post :select_phone, params: { locale: 'en', select_phone_form: INVALID_PHONE } }

      it 'renders iitself' do
        expect(subject).to render_template(:index)
      end
    end
  end

  context 'Analytics and Session:' do
    context 'when form is valid' do
      subject { post :select_phone, params: { locale: 'en', select_phone_form: VALID_PHONE } }

      before(:each) do
        expect(eligibility_checker).to receive(:any?)
      end

      it 'reports to Pwik' do
        expect(piwik_reporter).to receive(:report).with(anything, 'Phone Next')

        subject
      end

      it 'captures form values in session cookie' do
        expect(piwik_reporter).to receive(:report).with(any_args)

        subject

        expect(session[:selected_answers]["phone"]).to eq(mobile_phone: true, smart_phone: true, landline: true)
      end

      it 'does not store flash errors' do
        expect(piwik_reporter).to receive(:report).with(any_args)
        subject

        expect(flash[:errors]).to be_nil
      end
    end

    context 'when form is invalid' do
      subject { post :select_phone, params: { locale: 'en', select_phone_form: INVALID_PHONE } }

      it 'does not report to Pwik' do
        expect(piwik_reporter).not_to receive(:report)

        subject
      end

      it 'does not capture form values in session cookie' do
        subject

        expect(session[:selected_answers]).to eq(nil)
      end

      it 'stores flash errors' do
        subject

        expect(flash[:errors]).not_to be_empty
      end
    end
  end
end
