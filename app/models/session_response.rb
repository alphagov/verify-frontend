class SessionResponse < Api::Response
  attr_reader :session_id, :transaction_simple_id, :levels_of_assurance, :transaction_supports_eidas, :transaction_entity_id
  validates :session_id, :transaction_simple_id, :levels_of_assurance, presence: true
  validates :transaction_supports_eidas, inclusion: { in: [true, false] }


  def initialize(hash)
    @session_id = hash['sessionId']
    @transaction_simple_id = hash['transactionSimpleId']
    @transaction_entity_id = hash['transactionEntityId']
    @levels_of_assurance = hash['levelsOfAssurance']
    @transaction_supports_eidas = hash['transactionSupportsEidas']
  end
end
