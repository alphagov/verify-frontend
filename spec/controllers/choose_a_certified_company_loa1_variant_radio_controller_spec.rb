require 'rails_helper'
require 'controller_helper'
require 'api_test_helper'
require 'piwik_test_helper'

describe ChooseACertifiedCompanyLoa1VariantRadioController do
  let(:stub_idp_loa1) {
    {
        'simpleId' => 'stub-idp-loa1',
        'entityId' => 'http://idcorp-loa1.com',
        'levelsOfAssurance' => %w(LEVEL_1 LEVEL_2)
    }.freeze
  }

  let(:stub_idp_one_doc) {
    {
        'simpleId' => 'stub-idp-one-doc-question',
        'entityId' => 'http://idcorp.com',
        'levelsOfAssurance' => ['LEVEL_2']
    }.freeze
  }

  let(:stub_idp_loa1_onboarding) {
    {
        'simpleId' => 'stub-idp-loa1-onboarding',
        'entityId' => 'http://idcorp-loa1-onboarding.com',
        'levelsOfAssurance' => %w(LEVEL_1 LEVEL_2)
    }.freeze
  }

  let(:stub_idp_no_interstitial) {
    {
        'simpleId' => 'stub-idp-two',
        'entityId' => 'http://idcorp-two.com',
        'levelsOfAssurance' => ['LEVEL_1']
    }.freeze
  }

  context '#index' do
    before :each do
      stub_const('LOA1_ONBOARDING_IDPS', ['stub-idp-loa1-onboarding'])
      stub_api_idp_list([stub_idp_loa1, stub_idp_one_doc, stub_idp_loa1_onboarding])
    end

    it 'renders IDPs including onboarding IDPs when the RP is test-rp' do
      set_session_and_cookies_with_loa('LEVEL_1', 'test-rp')
      stub_piwik_request = stub_piwik_report_number_of_recommended_ipds(2, 'LEVEL_1', 'analytics description for test-rp')

      expect(IDENTITY_PROVIDER_DISPLAY_DECORATOR).to receive(:decorate_collection).once do |idps|
        idps.each { |idp| expect(idp.levels_of_assurance).to include 'LEVEL_1' }
      end

      get :index, params: { locale: 'en' }

      expect(subject).to render_template(:choose_a_certified_company_LOA1)
      expect(stub_piwik_request).to have_been_made.once
    end

    it 'renders IDPs excluding onboarding IDPs when the RP is anything other than test-rp' do
      set_session_and_cookies_with_loa('LEVEL_1', 'test-rp-no-demo')
      stub_piwik_request = stub_piwik_report_number_of_recommended_ipds(1, 'LEVEL_1', 'TEST RP NO DEMO')

      expect(IDENTITY_PROVIDER_DISPLAY_DECORATOR).to receive(:decorate_collection).once do |idps|
        idps.each { |idp| expect(idp.levels_of_assurance).to include 'LEVEL_1' }
      end

      get :index, params: { locale: 'en' }

      expect(subject).to render_template(:choose_a_certified_company_LOA1)
      expect(stub_piwik_request).to have_been_made.once
    end
  end

  context '#select_idp' do
    before :each do
      set_session_and_cookies_with_loa('LEVEL_1')
      stub_api_idp_list([stub_idp_loa1, stub_idp_one_doc])
      stub_api_select_idp
    end

    it 'sets selected IDP in user session' do
      post :select_idp, params: { locale: 'en', entity_id: 'http://idcorp-loa1.com' }

      expect(session[:selected_idp].entity_id).to eql('http://idcorp-loa1.com')
    end

    it 'checks whether IDP was recommended' do
      post :select_idp, params: { locale: 'en', entity_id: 'http://idcorp-loa1.com' }

      expect(session[:selected_idp_was_recommended]).to eql(true)
    end

    it 'redirects to IDP by default' do
      stub_api_idp_list([stub_idp_no_interstitial])
      post :select_idp, params: { locale: 'en', entity_id: 'http://idcorp-two.com' }

      expect(subject).to redirect_to redirect_to_idp_register_path
    end

    it 'redirects to IDP question page for LOA1 users when IDP flag is enabled' do
      post :select_idp, params: { locale: 'en', entity_id: 'http://idcorp-loa1.com' }

      expect(subject).to redirect_to redirect_to_idp_question_path
    end

    it 'returns 404 page if IDP is non-existent' do
      post :select_idp, params: { locale: 'en', entity_id: 'http://notanidp.com' }

      expect(response).to have_http_status :not_found
    end

    it 'displays validation error when no IDP selected' do
      post :select_idp, params: { locale: 'en', entity_id: '' }

      expect(subject).to render_template('choose_a_certified_company_variant_radio/choose_a_certified_company_LOA1')
      expect(flash[:errors]).not_to be_empty
    end
  end
end
