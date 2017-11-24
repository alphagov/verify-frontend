class SignInProcessDetailsResponse < Api::Response
  attr_reader :transaction_supports_eidas, :transaction_entity_id
  validates :transaction_entity_id, presence: true
  validates :transaction_supports_eidas, inclusion: { in: [true, false] }

  def initialize(hash)
    @transaction_entity_id = hash['transactionEntityId']
    @transaction_supports_eidas = hash['transactionSupportsEidas']
  end
end
