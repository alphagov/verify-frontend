require 'rails_helper'
require 'controller_helper'
require 'api_test_helper'

describe AboutLoa2VariantController do
  let(:identity_provider_display_decorator) { double(:IdentityProviderDisplayDecorator) }

  before(:each) do
    stub_request(:get, CONFIG.config_api_host + '/config/transactions/enabled')
    stub_api_idp_list_for_loa
  end

  context 'GET about#choosing_a_company' do
    subject { get :choosing_a_company, params: { locale: 'en' } }

    it 'renders the choosing a company LOA2 variant template when LEVEL_2 is the requested LOA' do
      set_session_and_cookies_with_loa('LEVEL_2')
      expect(subject).to render_template(:choosing_a_company)
    end
  end

  context 'GET about#identity_accounts' do
    subject { get :identity_accounts, params: { locale: 'en' } }

    it 'renders the identity accounts LOA2 variant template when LEVEL_2 is the requested LOA' do
      set_session_and_cookies_with_loa('LEVEL_2')
      expect(subject).to render_template(:identity_accounts_LOA2_variant)
    end
  end
end
