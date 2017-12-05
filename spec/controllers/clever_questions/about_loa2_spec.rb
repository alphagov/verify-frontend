require 'rails_helper'
require 'controller_helper'
require 'api_test_helper'

describe CleverQuestions::AboutLoa2Controller do
  let(:identity_provider_display_decorator) { double(:IdentityProviderDisplayDecorator) }

  before(:each) do
    stub_request(:get, CONFIG.config_api_host + '/config/transactions/enabled')
    stub_api_idp_list_for_loa
  end

  context 'GET about#identity_providers' do
    subject { get :identity_providers, params: { locale: 'en' } }

    before(:each) do
      stub_const('IDENTITY_PROVIDER_DISPLAY_DECORATOR', identity_provider_display_decorator)
    end

    it 'renders the identity providers LOA2 template when LEVEL_2 is the requested LOA' do
      set_session_and_cookies_with_loa('LEVEL_2')
      expect(identity_provider_display_decorator).to receive(:decorate_collection).and_return([])
      expect(subject).to render_template(:identity_providers_LOA2)
    end
  end

  context 'GET about#choosing_an_identity_provider' do
    subject { get :choosing_an_identity_provider, params: { locale: 'en' } }

    it 'renders the about choosing an identity provider LOA2 template when LEVEL_2 is the requested LOA' do
      set_session_and_cookies_with_loa('LEVEL_2')
      expect(subject).to render_template(:choosing_an_identity_provider)
    end
  end
end
