require 'rails_helper'
require 'controller_helper'

describe ConfirmationController do
  let(:identity_provider_display_decorator) { double(:IdentityProviderDisplayDecorator) }
  let(:repository) { double(:repository) }
  let(:display_data) { double(:display_data) }

  subject { get :index, params: { locale: 'en' } }

  it 'renders the confirmation LOA1 template when LEVEL_1 is the requested LOA' do
    stub_session
    set_session_and_cookies_with_loa('LEVEL_1')
    loa_identity_provider = IdentityProvider.new('simple_id' => 'stub-idp-loa1',
                                                 'entity_id' => 'http://idcorp.com',
                                                 'levels_of_assurance' => %w(LEVEL_1 LEVEL_2))

    LoaRecommended = Struct.new(
        :identity_provider,
        :display_data,
        :logo_path,
        :white_logo_path
    ) do
      delegate :entity_id, to: :identity_provider
      delegate :simple_id, to: :identity_provider
      delegate :model_name, to: :identity_provider
      delegate :to_key, to: :identity_provider
      delegate :display_name, :about_content, :requirements, :special_no_docs_instructions, :no_docs_requirement, :contact_details, :interstitial_question, :tagline, to: :display_data
    end

    loa_recommended = LoaRecommended.new(loa_identity_provider, display_data, 'idp-logos/barclays.png', 'idp-logos-white/barclays.png')

    stub_const('IDENTITY_PROVIDER_DISPLAY_DECORATOR', identity_provider_display_decorator)
    expect(identity_provider_display_decorator).to receive(:decorate) { |idps|
      expect(idps.first).to have_attributes(simple_id: loa_identity_provider.simple_id,
                                            entity_id: loa_identity_provider.entity_id,
                                            levels_of_assurance: loa_identity_provider.levels_of_assurance)
    }.and_return(loa_recommended)
    expect(loa_recommended).to receive(:display_name).and_return('idp-display-name')
    stub_const('RP_DISPLAY_REPOSITORY', repository)
    expect(repository).to receive(:fetch).with(instance_of(String)).and_return('current_transaction_simple_id')
    expect(subject).to render_template(:confirmation_LOA1)
    expect(subject).to_not render_template(:confirmation_LOA2)
  end

  it 'renders the confirmation LOA2 template when LEVEL_2 is the requested LOA' do
    set_session_and_cookies_with_loa('LEVEL_2')
    expect(subject).to render_template(:confirmation_LOA2)
    expect(subject).to_not render_template(:confirmation_LOA1)
  end
end
