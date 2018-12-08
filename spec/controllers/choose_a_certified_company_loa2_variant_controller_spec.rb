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
      session[:selected_answers] = {
        'documents' => { 'driving_licence' => true, 'mobile_phone' => true },
        'device_type' => { 'device_type_other' => true }
      }
      stub_piwik_request = stub_piwik_report_number_of_recommended_idps(1, 'LEVEL_2', 'analytics description for test-rp')

      expect(IDENTITY_PROVIDER_DISPLAY_DECORATOR).to receive(:decorate_collection).twice do |idps|
        idps.each { |idp| expect(idp.levels_of_assurance).to include 'LEVEL_2' }
      end

      get :index, params: { locale: 'en' }

      expect(subject).to render_template(:choose_a_certified_company_LOA2_variant)
      expect(stub_piwik_request).to have_been_made.once
    end

    it 'removes interstitial answer when IDP picker page is rendered' do
      set_session_and_cookies_with_loa('LEVEL_2')
      stub_api_idp_list_for_loa([stub_idp_loa1, stub_idp_one_doc])
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
end
