require 'rails_helper'
require 'controller_helper'
require 'api_test_helper'

describe ChooseACertifiedCompanyController do
  before :each do
    stub_api_idp_list([{ 'simpleId' => 'stub-idp-loa1',
                         'entityId' => 'http://idcorp-loa1.com',
                         'levelsOfAssurance' => %w(LEVEL_1 LEVEL_2) },
                       { 'simpleId' => 'stub-idp-one-doc-question',
                         'entityId' => 'http://idcorp.com',
                         'levelsOfAssurance' => ['LEVEL_2'] }])
  end

  context '#index' do
    subject { get :index, params: { locale: 'en' } }

    it 'renders the certified companies LOA1 template with LOA1 IDPs when LEVEL_1 is the requested LOA' do
      set_session_and_cookies_with_loa('LEVEL_1')

      expect(IDENTITY_PROVIDER_DISPLAY_DECORATOR).to receive(:decorate_collection) do |idps|
        idps.each { |idp| expect(idp.levels_of_assurance).to include 'LEVEL_1' }
      end
      expect(subject).to render_template(:choose_a_certified_company_LOA1)
    end

    it 'renders the certified companies LOA2 template when LEVEL_2 is the requested LOA' do
      set_session_and_cookies_with_loa('LEVEL_2')

      expect(IDENTITY_PROVIDER_DISPLAY_DECORATOR).to receive(:decorate_collection).twice do |idps|
        idps.each { |idp| expect(idp.levels_of_assurance).to include 'LEVEL_2' }
      end
      expect(subject).to render_template(:choose_a_certified_company_LOA2)
    end
  end

  context '#select_idp' do
    before :each do
      set_session_and_cookies_with_loa('LEVEL_2')
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

    it 'returns 404 page if IDP is non-existent' do
      post :select_idp, params: { locale: 'en', entity_id: 'http://notanidp.com' }

      expect(response).to have_http_status :not_found
    end
  end

  context '#about' do
    it 'returns 404 page if no display data exists for IDP' do
      set_session_and_cookies_with_loa('LEVEL_2')
      get :about, params: { locale: 'en', company: 'unknown-idp' }

      expect(subject).to render_template 'errors/404'
      expect(response).to have_http_status :not_found
    end
  end
end
