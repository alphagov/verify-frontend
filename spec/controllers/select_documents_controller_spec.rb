require 'rails_helper'
require 'controller_helper'
require 'spec_helper'
require 'api_test_helper'
require 'piwik_test_helper'
require 'models/display/viewable_identity_provider'

describe SelectDocumentsController do
  before(:each) do
    set_session_and_cookies_with_loa('LEVEL_2')
  end

  context 'when form is valid' do
    before :each do
      stub_piwik_request('action_name' => 'Select Documents Next')
    end

    it 'redirects to other identity documents page when further documents are required' do
      further_documents_evidence = { passport: 'false', any_driving_licence: 'false' }.freeze
      post :select_documents, params: { locale: 'en', select_documents_form: further_documents_evidence }

      expect(subject).to redirect_to other_identity_documents_path
    end

    it 'redirects to select phone page when no further documents are required' do
      no_further_documents_evidence = { passport: 'true', any_driving_licence: 'false' }.freeze
      post :select_documents, params: { locale: 'en', select_documents_form: no_further_documents_evidence }

      expect(subject).to redirect_to select_phone_path
    end

    it 'captures form values in session cookie' do
      documents_evidence = { passport: 'true',
                             any_driving_licence: 'true',
                             driving_licence: 'great_britain' }.freeze
      post :select_documents, params: { locale: 'en', select_documents_form: documents_evidence }

      subject
      expect(session[:selected_answers]['documents']).to eq(passport: true,
                                                            driving_licence: true,
                                                            ni_driving_licence: false)
    end
  end

  context 'when form is invalid' do
    subject { post :select_documents, params: { locale: 'en' } }

    it 'renders itself' do
      expect(subject).to render_template(:index)
    end

    it 'does not capture form values in session cookie' do
      expect(session[:selected_answers]).to eq(nil)
    end

    it 'does not report to Piwik' do
      expect(ANALYTICS_REPORTER).not_to receive(:report_action)
    end
  end
end
