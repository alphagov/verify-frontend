class OutboundSamlMessage < Api::Response
  attr_reader :location, :saml_request, :relay_state, :registration
  validates_presence_of :location, :saml_request, :relay_state
  validates_inclusion_of :registration, in: [true, false]

  def initialize(hash)
    @location = hash["postEndpoint"]
    @saml_request = hash["samlMessage"]
    @relay_state = hash["relayState"]
    @registration = hash["registration"]
  end
end
