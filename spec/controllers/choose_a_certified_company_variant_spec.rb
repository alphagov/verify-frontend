require 'rails_helper'
require 'controller_helper'
require 'spec_helper'
require 'api_test_helper'

describe ChooseACertifiedCompanyVariantController do
  let(:identity_provider_display_decorator) { double(:IdentityProviderDisplayDecorator) }
  let(:repository) { double(:repository) }
  let(:display_data) { double(:display_data) }

  render_views
  subject { get :index, params: { locale: 'en' } }

  LOARecommended = Struct.new(
    :identity_provider,
    :display_data,
    :logo_path,
    :white_logo_path
  ) do
    delegate :entity_id, to: :identity_provider
    delegate :simple_id, to: :identity_provider
    delegate :model_name, to: :identity_provider
    delegate :to_key, to: :identity_provider
    delegate :display_name, :about_content, :requirements, :special_no_docs_instructions, :no_docs_requirement, :contact_details, :interstitial_question, :mobile_app_installation, :tagline, to: :display_data
  end

  context 'Level of Assurance 1' do
    before(:each) do
      stub_api_idp_list([{ 'simpleId' => 'stub-idp-loa1',
                           'entityId' => 'http://idcorp.com',
                           'levelsOfAssurance' => %w(LEVEL_1 LEVEL_2) },
                         { 'simpleId' => 'stub-idp-loa2',
                           'entityId' => 'http://idcorp.com',
                           'levelsOfAssurance' => ['LEVEL_2'] }])

      loa_identity_provider = IdentityProvider.new('simpleId' => 'stub-idp-loa1',
                                                   'entityId' => 'http://idcorp.com',
                                                   'levelsOfAssurance' => %w(LEVEL_1 LEVEL_2))

      stub_const('IDENTITY_PROVIDER_DISPLAY_DECORATOR', identity_provider_display_decorator)

      loa_recommended = LOARecommended.new(loa_identity_provider, display_data, 'idp-logos/barclays.png', 'idp-logos-white/barclays.png')

      expect(identity_provider_display_decorator).to receive(:decorate_collection) { |idps|
        expect(idps.first).to have_attributes(simple_id: loa_identity_provider.simple_id,
                                              entity_id: loa_identity_provider.entity_id,
                                              levels_of_assurance: loa_identity_provider.levels_of_assurance)
      }.and_return([loa_recommended])
      expect(display_data).to receive(:display_name).at_least(1).times.and_return('stub')
    end

    context 'renders LOA1 template' do
      it 'when LEVEL_1 is the requested LOA' do
        set_session_and_cookies_with_loa('LEVEL_1')

        expect(subject).to render_template(:choose_a_certified_company_LOA1)
        expect(subject).to_not render_template(:choose_a_certified_company_LOA2)
        expect(response.body).to have_css('button[name="stub-idp-loa1"]')
      end
    end

    context 'mobile app installation message' do
      before(:each) do
        set_session_and_cookies_with_loa('LEVEL_1')
      end

      it 'is rendered when IDP requires app installation' do
        session[:reluctant_mob_installation] = true
        expect(display_data).to receive(:mobile_app_installation).at_least(1).times.and_return('You will need to install an app')

        subject

        expect(response.body).to include("You will need to install an app")
      end

      it 'is not rendered when IDP does not require app installation' do
        session[:reluctant_mob_installation] = false
        expect(display_data).not_to receive(:mobile_app_installation)

        subject
      end
    end
  end

  it 'renders the certified companies LOA2 template when LEVEL_2 is the requested LOA' do
    stub_api_idp_list([{ 'simpleId' => 'stub-idp-loa1',
                         'entityId' => 'http://idcorp.com',
                         'levelsOfAssurance' => %w(LEVEL_1 LEVEL_2) },
                       { 'simpleId' => 'stub-idp-loa2',
                         'entityId' => 'http://idcorp.com',
                         'levelsOfAssurance' => ['LEVEL_2'] }])

    set_session_and_cookies_with_loa('LEVEL_2')
    expect(subject).to render_template(:choose_a_certified_company_LOA2)
    expect(subject).to_not render_template(:choose_a_certified_company_LOA1)
  end
end
