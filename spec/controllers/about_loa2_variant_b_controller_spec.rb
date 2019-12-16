require 'rails_helper'
require 'controller_helper'
require 'api_test_helper'
require 'variant_test_helper'

describe AboutLoa2VariantBController do
  let(:identity_provider_display_decorator) { double(:IdentityProviderDisplayDecorator) }

  before(:each) do
    stub_request(:get, CONFIG.config_api_host + '/config/transactions/enabled')
    experiment = 'short_hub_2019_q3-preview'
    variant = 'variant_b_2_idp'
    set_session_and_cookies_with_loa_and_variant('LEVEL_2', experiment, variant)
    stub_api_idp_list_for_loa
  end

  context 'GET about#certified_companies' do
    subject { get :certified_companies, params: { locale: 'en' } }

    before(:each) do
      stub_const('IDENTITY_PROVIDER_DISPLAY_DECORATOR', identity_provider_display_decorator)
    end

    it 'renders the LOA2 certified companies for variant B on the certified_companies view' do
      expect(identity_provider_display_decorator).to receive(:decorate_collection).with(a_list_of_size(3)).and_return([])
      expect(subject).to render_template(:certified_companies_LOA2)
    end
  end

  context 'GET about#identity_accounts' do
    subject { get :identity_accounts, params: { locale: 'en' } }

    it 'renders the identity accounts LOA2 template when LEVEL_2 is the requested LOA' do
      expect(subject).to render_template(:identity_accounts_LOA2)
    end
  end

  context 'GET about#choosing_a_company' do
    subject { get :choosing_a_company, params: { locale: 'en' } }

    it 'renders the choosing a company LOA2 template when LEVEL_2 is the requested LOA' do
      expect(subject).to render_template(:choosing_a_company)
    end
  end
end
