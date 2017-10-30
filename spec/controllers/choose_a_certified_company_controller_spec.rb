require 'rails_helper'
require 'controller_helper'
require 'api_test_helper'
require 'piwik_test_helper'

describe ChooseACertifiedCompanyController do
  STUB_IDP_LOA1 = {
      'simpleId' => 'stub-idp-loa1',
      'entityId' => 'http://idcorp-loa1.com',
      'levelsOfAssurance' => %w(LEVEL_1 LEVEL_2)
  }.freeze

  STUB_IDP_ONE_DOC = {
      'simpleId' => 'stub-idp-one-doc-question',
      'entityId' => 'http://idcorp.com',
      'levelsOfAssurance' => ['LEVEL_2']
  }.freeze

  STUB_IDP_LOA1_ONBOARDING = {
      'simpleId' => 'stub-idp-loa1-onboarding',
      'entityId' => 'http://idcorp-loa1-onboarding.com',
      'levelsOfAssurance' => %w(LEVEL_1 LEVEL_2)
  }.freeze

  context '#index' do
    before :each do
      stub_const('LOA1_ONBOARDING_IDPS', ['stub-idp-loa1-onboarding'])
      stub_api_idp_list([STUB_IDP_LOA1, STUB_IDP_ONE_DOC, STUB_IDP_LOA1_ONBOARDING])
    end

    context 'LoA1' do
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

    context 'LoA2' do
      it 'renders the certified companies LOA2 template when LEVEL_2 is the requested LOA' do
        set_session_and_cookies_with_loa('LEVEL_2')
        stub_api_idp_list([STUB_IDP_LOA1, STUB_IDP_ONE_DOC])
        session[:selected_answers] = { documents: { driving_licence: true, mobile_phone: true } }
        stub_piwik_request = stub_piwik_report_number_of_recommended_ipds(1, 'LEVEL_2', 'analytics description for test-rp')

        expect(IDENTITY_PROVIDER_DISPLAY_DECORATOR).to receive(:decorate_collection).twice do |idps|
          idps.each { |idp| expect(idp.levels_of_assurance).to include 'LEVEL_2' }
        end

        get :index, params: { locale: 'en' }

        expect(subject).to render_template(:choose_a_certified_company_LOA2)
        expect(stub_piwik_request).to have_been_made.once
      end
    end
  end

  context '#select_idp' do
    before :each do
      set_session_and_cookies_with_loa('LEVEL_2')
      stub_api_idp_list([STUB_IDP_LOA1, STUB_IDP_ONE_DOC])
    end

    it 'resets interstitial answer to no value when IDP is selected' do
      session[:selected_answers] = { 'interstitial' => { 'interstitial_yes' => true } }
      post :select_idp, params: { locale: 'en', entity_id: 'http://idcorp.com' }

      expect(session[:selected_answers]['interstitial']).to be_empty
    end

    it 'sets selected IDP in user session' do
      post :select_idp, params: { locale: 'en', entity_id: 'http://idcorp.com' }

      expect(session[:selected_idp].entity_id).to eql('http://idcorp.com')
    end

    it 'checks whether IDP was recommended' do
      session[:selected_answers] = {
        'documents' => { 'driving_licence' => true, 'passport' => false },
        'phone' => { 'mobile_phone' => true }
      }
      post :select_idp, params: { locale: 'en', entity_id: 'http://idcorp.com' }

      expect(session[:selected_idp_was_recommended]).to eql(true)
    end

    it 'redirects to IDP warning page by default' do
      session[:selected_answers] = { 'documents' => { 'driving_licence' => true, 'passport' => true } }
      post :select_idp, params: { locale: 'en', entity_id: 'http://idcorp-loa1.com' }

      expect(subject).to redirect_to redirect_to_idp_warning_path
    end

    it 'redirects to IDP question page when user has one doc and IDP flag is enabled' do
      session[:selected_answers] = { 'documents' => { 'driving_licence' => true } }
      post :select_idp, params: { locale: 'en', entity_id: 'http://idcorp.com' }

      expect(subject).to redirect_to redirect_to_idp_question_path
    end

    it 'redirects to IDP question page for LOA1 users when IDP flag is enabled' do
      set_session_and_cookies_with_loa('LEVEL_1')
      post :select_idp, params: { locale: 'en', entity_id: 'http://idcorp-loa1.com' }

      expect(subject).to redirect_to redirect_to_idp_question_path
    end

    it 'returns 404 page if IDP is non-existent' do
      post :select_idp, params: { locale: 'en', entity_id: 'http://notanidp.com' }

      expect(response).to have_http_status :not_found
    end
  end

  context '#about' do
    it 'returns 404 page if no display data exists for IDP' do
      set_session_and_cookies_with_loa('LEVEL_2')
      stub_api_idp_list([STUB_IDP_LOA1, STUB_IDP_ONE_DOC])

      get :about, params: { locale: 'en', company: 'unknown-idp' }

      expect(subject).to render_template 'errors/404'
      expect(response).to have_http_status :not_found
    end
  end
end
