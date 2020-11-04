class SignInProcessDetailsResponse < Api::Response
  attr_reader :transaction_supports_eidas, :transaction_entity_id, :before_eu_exit
  validates :transaction_entity_id, presence: true
  validates :transaction_supports_eidas, inclusion: { in: [true, false] }
  validates :before_eu_exit, inclusion: { in: [true, false] }

  def initialize(hash)
    @transaction_entity_id = hash["requestIssuerId"]
    @transaction_supports_eidas = hash["transactionSupportsEidas"]
    @before_eu_exit = hash["beforeEUExit"]
  end
end
