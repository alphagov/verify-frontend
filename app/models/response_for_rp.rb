class ResponseForRp < Api::Response
  attr_reader :location, :saml_message, :relay_state
  validates_presence_of :location, :saml_message

  def initialize(hash)
    @location = hash['postEndpoint']
    @saml_message = hash['samlMessage']
    @relay_state = hash['relayState']
  end
end
