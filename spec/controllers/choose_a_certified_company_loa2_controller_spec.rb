require 'rails_helper'
require 'controller_helper'
require 'api_test_helper'
require 'piwik_test_helper'

describe ChooseACertifiedCompanyLoa2Controller do
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
        'levelsOfAssurance' => %w(LEVEL_2)
    }.freeze
  }

  context '#index' do
    it 'renders the certified companies LOA2 template when LEVEL_2 is the requested LOA' do
      set_session_and_cookies_with_loa('LEVEL_2')
      stub_api_idp_list_for_registration([stub_idp_loa1, stub_idp_one_doc])
      session[:selected_answers] = {
        'documents' => { 'driving_licence' => true, 'mobile_phone' => true },
        'device_type' => { 'device_type_other' => true }
      }
      stub_piwik_request = stub_piwik_report_number_of_recommended_idps(1, 'LEVEL_2', 'analytics description for test-rp')

      expect(IDENTITY_PROVIDER_DISPLAY_DECORATOR).to receive(:decorate_collection).twice do |idps|
        idps.each { |idp| expect(idp.levels_of_assurance).to include 'LEVEL_2' }
      end

      get :index, params: { locale: 'en' }

      expect(subject).to render_template(:choose_a_certified_company_LOA2)
      expect(stub_piwik_request).to have_been_made.once
    end

    it 'removes interstitial answer when IDP picker page is rendered' do
      set_session_and_cookies_with_loa('LEVEL_2')
      stub_api_idp_list_for_registration([stub_idp_loa1, stub_idp_one_doc])
      session[:selected_answers] = {
        'documents' => { 'driving_licence' => true, 'mobile_phone' => true },
        'device_type' => { 'device_type_other' => true },
        'interstitial' => { 'interstitial_yes' => true }
      }
      stub_piwik_report_number_of_recommended_idps(1, 'LEVEL_2', 'analytics description for test-rp')

      get :index, params: { locale: 'en' }

      expect(session[:selected_answers]['interstitial']).to be_nil
    end
  end

  context '#select_idp' do
    before :each do
      set_session_and_cookies_with_loa('LEVEL_2')
      stub_api_idp_list_for_registration([stub_idp_loa1, stub_idp_one_doc])
    end

    it 'sets selected IDP in user session' do
      post :select_idp, params: { locale: 'en', entity_id: 'http://idcorp.com' }

      expect(session[:selected_provider].entity_id).to eql('http://idcorp.com')
    end

    it 'checks whether IDP was recommended' do
      session[:selected_answers] = {
        'documents' => { 'driving_licence' => true, 'passport' => false },
        'phone' => { 'mobile_phone' => true },
        'device_type' => { 'device_type_other' => true }
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

    it 'redirects to IDP question page when user has zero docs and IDP flag is enabled' do
      session[:selected_answers] = { 'documents' => { 'driving_licence' => false } }
      post :select_idp, params: { locale: 'en', entity_id: 'http://idcorp.com' }

      expect(subject).to redirect_to redirect_to_idp_question_path
    end

    it 'returns 404 page if IDP is non-existent' do
      post :select_idp, params: { locale: 'en', entity_id: 'http://notanidp.com' }

      expect(response).to have_http_status :not_found
    end

    it 'returns 400 if `entity_id` param is not present' do
      post :select_idp, params: { locale: 'en' }

      expect(subject).to render_template 'errors/something_went_wrong'
      expect(response).to have_http_status :bad_request
    end
  end

  context '#about' do
    it 'returns 404 page if no display data exists for IDP' do
      set_session_and_cookies_with_loa('LEVEL_2')
      stub_api_idp_list_for_registration([stub_idp_loa1, stub_idp_one_doc])

      get :about, params: { locale: 'en', company: 'unknown-idp' }

      expect(subject).to render_template 'errors/404'
      expect(response).to have_http_status :not_found
    end
  end
end
