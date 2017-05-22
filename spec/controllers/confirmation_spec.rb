require 'rails_helper'
require 'controller_helper'
require 'spec_helper'
require 'models/display/viewable_identity_provider'

describe ConfirmationController do
  let(:identity_provider_display_decorator) { double(:IdentityProviderDisplayDecorator) }
  let(:repository) { double(:repository) }
  let(:display_data) { double(:display_data) }
  entity_id = 'http://idcorp.com'
  simple_id = 'stub-idp-loa'
  levels_of_assurance = %w(LEVEL_1 LEVEL_2)
  transaction_simple_id = 'test-rp'

  subject { get :index, params: { locale: 'en' } }

  before(:each) do
    session[:selected_idp] = {'entity_id' => entity_id, 'simple_id' => simple_id, 'levels_of_assurance' => levels_of_assurance}
    session[:transaction_simple_id] = transaction_simple_id

    stub_const('IDENTITY_PROVIDER_DISPLAY_DECORATOR', stub_identity_provider_display_decorator(identity_provider_display_decorator, simple_id, entity_id, levels_of_assurance))
    stub_const('RP_DISPLAY_REPOSITORY', stub_rp_display_repository(transaction_simple_id))
  end

  it 'renders the confirmation LOA1 template when LEVEL_1 is the requested LOA' do
    set_session_and_cookies_with_loa('LEVEL_1')

    expect(subject).to render_template(:confirmation_LOA1)
    expect(subject).to_not render_template(:confirmation_LOA2)
  end

  it 'renders the confirmation LOA2 template when LEVEL_2 is the requested LOA' do
    set_session_and_cookies_with_loa('LEVEL_2')

    expect(subject).to render_template(:confirmation_LOA2)
    expect(subject).to_not render_template(:confirmation_LOA1)
  end
end


def stub_identity_provider_display_decorator(identity_provider_display_decorator, simple_id, entity_id, levels_of_assurance)
  loa_identity_provider = IdentityProvider.new('simple_id' => simple_id,
                                               'entity_id' => entity_id,
                                               'levels_of_assurance' => levels_of_assurance)

  viewable_identity_provider_stub = Display::ViewableIdentityProvider.new(loa_identity_provider, display_data, 'idp-logos/barclays.png', 'idp-logos-white/barclays.png')

  expect(identity_provider_display_decorator).to receive(:decorate) { |identity_provider|
    expect(identity_provider).to have_attributes(simple_id: simple_id,
                                                 entity_id: entity_id,
                                                 levels_of_assurance: levels_of_assurance)
  }.and_return(viewable_identity_provider_stub)
  expect(viewable_identity_provider_stub).to receive(:display_name).and_return('idp-display-name')

  identity_provider_display_decorator
end

def stub_rp_display_repository(transaction_simple_data)
  current_transaction = ""

  def current_transaction.name
    "Test-RP"
  end
  { transaction_simple_data => current_transaction }
end
