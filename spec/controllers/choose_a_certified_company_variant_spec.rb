require 'rails_helper'
require 'controller_helper'
require 'spec_helper'
require 'api_test_helper'

describe ChooseACertifiedCompanyVariantController do
  subject { get :index, params: { locale: 'en' } }

  context 'Level of Assurance 1' do
    before(:each) do
      stub_api_idp_list([{ 'simpleId' => 'stub-idp-loa1',
                           'entityId' => 'http://idcorp.com',
                           'levelsOfAssurance' => %w(LEVEL_1 LEVEL_2) },
                         { 'simpleId' => 'stub-idp-loa2',
                           'entityId' => 'http://idcorp.com',
                           'levelsOfAssurance' => ['LEVEL_2'] }])
    end

    it 'renders the LOA1 template with LOA1 IDPs when LEVEL_1 is the requested LOA' do
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

    it 'resets interstitial answer to no value when IDP is selected' do
      set_session_and_cookies_with_loa('LEVEL_2')
      session[:selected_answers] = { 'interstitial' => { 'interstitial_yes' => true } }

      post :select_idp, params: { locale: 'en', entity_id: 'http://idcorp.com' }

      expect(session[:selected_answers]['interstitial']).to eq({})
    end
  end
end
