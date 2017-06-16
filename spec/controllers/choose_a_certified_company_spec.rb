require 'rails_helper'
require 'controller_helper'
require 'api_test_helper'

describe ChooseACertifiedCompanyController do
  let(:identity_provider_display_decorator) { double(:IdentityProviderDisplayDecorator) }
  let(:repository) { double(:repository) }
  let(:display_data) { double(:display_data) }

  before :each do
    stub_api_idp_list([{ 'simpleId' => 'stub-idp-loa1',
                         'entityId' => 'http://idcorp.com',
                         'levelsOfAssurance' => %w(LEVEL_1 LEVEL_2) },
                       { 'simpleId' => 'stub-idp-loa2',
                         'entityId' => 'http://idcorp.com',
                         'levelsOfAssurance' => ['LEVEL_2'] }])
  end

  subject { get :index, params: { locale: 'en' } }

  it 'filters LOA1 IDPs when requested LOA is LEVEL 1' do
    loa_identity_provider = IdentityProvider.new('simpleId' => 'stub-idp-loa1',
                                                 'entityId' => 'http://idcorp.com',
                                                 'levelsOfAssurance' => %w(LEVEL_1 LEVEL_2))
    loa_recommended = Display::ViewableIdentityProvider.new(loa_identity_provider, display_data, 'idp-logos/an_idp.png', 'idp-logos-white/an_idp.png')

    stub_const('IDENTITY_PROVIDER_DISPLAY_DECORATOR', identity_provider_display_decorator)

    expect(identity_provider_display_decorator).to receive(:decorate_collection) { |idps|
      expect(idps.first).to have_attributes(simple_id: loa_identity_provider.simple_id,
                                            entity_id: loa_identity_provider.entity_id,
                                            levels_of_assurance: loa_identity_provider.levels_of_assurance)
    }.and_return([loa_recommended])
    set_session_and_cookies_with_loa('LEVEL_1')

    subject
  end

  it 'renders the certified companies LOA1 template when LEVEL_1 is the requested LOA' do
    set_session_and_cookies_with_loa('LEVEL_1')

    expect(subject).to render_template(:choose_a_certified_company_LOA1)
  end

  it 'renders the certified companies LOA2 template when LEVEL_2 is the requested LOA' do
    set_session_and_cookies_with_loa('LEVEL_2')
    expect(subject).to render_template(:choose_a_certified_company_LOA2)
  end
end
