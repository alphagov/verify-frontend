require 'rails_helper'

RSpec.describe IdentityProviderRequest do
  it 'should wrap a saml request' do
    saml_message = OutboundSamlMessage.new(
      'location' => 'some_location',
      'samlRequest' => 'some_request',
      'relayState' => 'some_state',
      'registration' => 'some_reg')
    request = IdentityProviderRequest.new(saml_message, 'simple-id', {})
    expect(request.location).to eql('some_location')
    expect(request.saml_request).to eql('some_request')
    expect(request.relay_state).to eql('some_state')
    expect(request.registration).to eql('some_reg')
  end

  it 'should have hints when idp has hints is enabled' do
    saml_message = OutboundSamlMessage.new('registration' => true)
    answers_hash = { phone: { mobile_phone: true } }
    hints = ['has_mobile']

    allow(IDP_FEATURE_FLAGS_CHECKER).to receive(:enabled?).with(:send_hints, 'simple-id').and_return(true)
    allow(IDP_FEATURE_FLAGS_CHECKER).to receive(:enabled?).with(:send_language_hint, 'simple-id').and_return(false)
    allow(HintsMapper).to receive(:map_answers_to_hints).with(answers_hash).and_return(hints)

    request = IdentityProviderRequest.new(saml_message, 'simple-id', answers_hash)
    expect(request.hints).to eql(hints)
  end

  it 'should not have hints when idp has hints disabled' do
    saml_message = OutboundSamlMessage.new('registration' => true)
    answers_hash = { phone: { mobile_phone: true } }

    allow(IDP_FEATURE_FLAGS_CHECKER).to receive(:enabled?).with(:send_hints, 'simple-id').and_return(false)
    allow(IDP_FEATURE_FLAGS_CHECKER).to receive(:enabled?).with(:send_language_hint, 'simple-id').and_return(false)

    request = IdentityProviderRequest.new(saml_message, 'simple-id', answers_hash)
    expect(request.hints).to eql([])
  end

  it 'should not have hints when on the sign in flow' do
    saml_message = OutboundSamlMessage.new('registration' => false)
    answers_hash = { phone: { mobile_phone: true } }

    allow(IDP_FEATURE_FLAGS_CHECKER).to receive(:enabled?).with(:send_hints, 'simple-id').and_return(true)
    allow(IDP_FEATURE_FLAGS_CHECKER).to receive(:enabled?).with(:send_language_hint, 'simple-id').and_return(false)
    allow(HintsMapper).to receive(:map_answers_to_hints).with(answers_hash).and_return(['has_mobile'])

    request = IdentityProviderRequest.new(saml_message, 'simple-id', answers_hash)
    expect(request.hints).to eql([])
  end

  it 'should have language hint when idp has language hint enabled' do
    saml_message = OutboundSamlMessage.new('registration' => true)

    allow(I18n).to receive(:locale).and_return('en')
    allow(IDP_FEATURE_FLAGS_CHECKER).to receive(:enabled?).with(:send_hints, 'simple-id').and_return(false)
    allow(IDP_FEATURE_FLAGS_CHECKER).to receive(:enabled?).with(:send_language_hint, 'simple-id').and_return(true)

    request = IdentityProviderRequest.new(saml_message, 'simple-id', {})

    expect(request.language_hint).to eql('en')
  end

  it 'should not have language hint when idp has language hint disabled' do
    saml_message = OutboundSamlMessage.new('registration' => true)

    allow(IDP_FEATURE_FLAGS_CHECKER).to receive(:enabled?).with(:send_hints, 'simple-id').and_return(false)
    allow(IDP_FEATURE_FLAGS_CHECKER).to receive(:enabled?).with(:send_language_hint, 'simple-id').and_return(false)

    request = IdentityProviderRequest.new(saml_message, 'simple-id', {})
    expect(request.language_hint).to be_nil
  end
end
