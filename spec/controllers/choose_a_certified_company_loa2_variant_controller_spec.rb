require 'rails_helper'
require 'controller_helper'
require 'api_test_helper'
require 'piwik_test_helper'

describe ChooseACertifiedCompanyLoa2VariantController do
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

  context '#index' do
    it 'renders the certified companies LOA2 template when LEVEL_2 is the requested LOA' do
      set_session_and_cookies_with_loa('LEVEL_2')
      stub_api_idp_list_for_loa([stub_idp_loa1, stub_idp_one_doc])

      expect(IDENTITY_PROVIDER_DISPLAY_DECORATOR).to receive(:decorate_collection).once do |idps|
        idps.each { |idp| expect(idp.levels_of_assurance).to include 'LEVEL_2' }
      end

      get :index, params: { locale: 'en' }

      expect(subject).to render_template(:choose_a_certified_company_LOA2_variant)
    end
  end

  context '#select_idp' do
    before :each do
      set_session_and_cookies_with_loa('LEVEL_2')
      stub_api_idp_list_for_loa([stub_idp_loa1, stub_idp_one_doc])
    end

    it 'sets selected IDP in user session' do
      post :select_idp, params: { locale: 'en', entity_id: 'http://idcorp.com' }

      expect(session[:selected_idp].entity_id).to eql('http://idcorp.com')
      expect(response).to have_http_status :see_other
    end

    it 'redirects to IDP warning page by default' do
      post :select_idp, params: { locale: 'en', entity_id: 'http://idcorp-loa1.com' }

      expect(subject).to redirect_to redirect_to_idp_warning_path
    end

    it 'returns 404 page if IDP is non-existent' do
      post :select_idp, params: { locale: 'en', entity_id: 'http://notanidp.com' }

      expect(response).to have_http_status :not_found
    end
  end
end
