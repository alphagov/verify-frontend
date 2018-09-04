class IdentityProviderRequest
  attr_reader :location, :saml_request, :relay_state, :registration, :uuid, :hints, :language_hint

  def initialize(outbound_saml_message, simple_id, answers, uuid = nil)
    @location = outbound_saml_message.location
    @saml_request = outbound_saml_message.saml_request
    @relay_state = outbound_saml_message.relay_state
    @registration = outbound_saml_message.registration
    @uuid = uuid unless uuid.nil?
    @hints = get_hints(simple_id, answers, @registration)
    @language_hint = get_language_hint(simple_id)
  end

  def get_hints(simple_id, answers, registration)
    if IDP_FEATURE_FLAGS_CHECKER.enabled?(:send_hints, simple_id) && registration
      HintsMapper.map_answers_to_hints(answers)
    else
      []
    end
  end

  def get_language_hint(simple_id)
    I18n.locale if IDP_FEATURE_FLAGS_CHECKER.enabled?(:send_language_hint, simple_id)
  end
end
