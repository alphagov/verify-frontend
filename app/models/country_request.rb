class CountryRequest
  attr_reader :location, :saml_request, :relay_state, :registration

  def initialize(outbound_saml_message)
    @location = outbound_saml_message.location
    @saml_request = outbound_saml_message.saml_request
    @relay_state = outbound_saml_message.relay_state
    @registration = outbound_saml_message.registration
  end
end
