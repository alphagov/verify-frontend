require 'rails_helper'
require 'controller_helper'
require 'spec_helper'
require 'models/display/viewable_identity_provider'

describe SelectPhoneController do
  let(:piwik_reporter) { double(:Reporter) }
  let(:eligibility_checker) { double(:Checker) }

  before(:each) do
    set_session_and_cookies_with_loa('LEVEL_1')
    stub_const('ANALYTICS_REPORTER', piwik_reporter)
    stub_const('IDP_ELIGIBILITY_CHECKER', eligibility_checker)
  end

  context 'Form valid' do
    subject { post :select_phone, params: { locale: 'en', select_phone_form: { mobile_phone: 'true', smart_phone: 'true', landline: 'true' } } }

    before(:each) do
      expect(piwik_reporter).to receive(:report).with(any_args)
    end

    it 'redirects to choose certified company page when eligibile IDPs exist' do
      expect(eligibility_checker).to receive(:any?).with([:mobile_phone, :smart_phone, :landline], anything).and_return(true)

      expect(subject).to redirect_to('/choose-a-certified-company')
    end

    it 'redirects to no mobile phone page when no eligibile IDPs' do
      expect(eligibility_checker).to receive(:any?).with([:mobile_phone, :smart_phone, :landline], anything).and_return(false)

      expect(subject).to redirect_to('/no-mobile-phone')
    end
  end

  context 'Form Invalid' do
    subject { post :select_phone, params: { locale: 'en', select_phone_form: { mobile_phone: 'false', smart_phone: 'true' } } }

    it 'rerenders index' do
      expect(subject).to render_template(:index)
    end

    it 'stores flash errors' do
      subject

      expect(flash[:errors]).not_to be_empty
    end
  end

  context 'Analytics and Session' do
    context 'Valid Form' do
      subject { post :select_phone, params: { locale: 'en', select_phone_form: { mobile_phone: 'true', smart_phone: 'true', landline: 'true' } } }

      before(:each) do
        expect(eligibility_checker).to receive(:any?).with(any_args).and_return(true)
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
    end

    context 'Invalid Form' do
      subject { post :select_phone, params: { locale: 'en', select_phone_form: {} } }

      it 'does not report to Pwik' do
        expect(piwik_reporter).not_to receive(:report)

        subject
      end

      it 'does not capture form values in session cookie' do
        subject
        expect(session[:selected_answers]).to eq(nil)
      end
    end
  end
end
