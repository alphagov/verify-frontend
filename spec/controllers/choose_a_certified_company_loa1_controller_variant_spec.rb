require 'rails_helper'
require 'controller_helper'
require 'api_test_helper'
require 'piwik_test_helper'

describe ChooseACertifiedCompanyLoa1VariantController do
  let(:stub_idp_loa1) {
    {
        'simpleId' => 'stub-idp-loa1',
        'entityId' => 'http://idcorp-loa1.com',
        'levelsOfAssurance' => %w(LEVEL_1 LEVEL_2)
    }.freeze
  }

  let(:stub_idp_loa1_with_interstitial) {
    {
        'simpleId' => 'stub-idp-loa1-with-interstitial',
        'entityId' => 'http://idcorp-loa1-with-interstitial.com',
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
      stub_api_idp_list_for_loa([stub_idp_loa1, stub_idp_loa1_with_interstitial], 'LEVEL_1')
    end

    it 'renders IDP list' do
      set_session_and_cookies_with_loa('LEVEL_1', 'test-rp')
      stub_piwik_request = stub_piwik_report_number_of_recommended_idps(2, 'LEVEL_1', 'analytics description for test-rp')

      expect(IDENTITY_PROVIDER_DISPLAY_DECORATOR_VARIANT).to receive(:decorate_collection).once do |idps|
        idps.each { |idp| expect(idp.levels_of_assurance).to include 'LEVEL_1' }
      end

      get :index, params: { locale: 'en' }

      expect(subject).to render_template(:choose_a_certified_company_LOA1)
      expect(stub_piwik_request).to have_been_made.once
    end
  end
end
