class SessionResponse < Api::Response
  attr_reader :session_id, :transaction_simple_id, :idps, :levels_of_assurance, :transaction_supports_eidas
  validates :session_id, :transaction_simple_id, :idps, :levels_of_assurance, presence: true

  def initialize(hash)
    @session_id = hash['sessionId']
    @transaction_simple_id = hash['transactionSimpleId']
    @idps = hash['idps']
    @levels_of_assurance = hash['levelsOfAssurance']
    @transaction_supports_eidas = hash['transactionSupportsEidas']
  end
end
