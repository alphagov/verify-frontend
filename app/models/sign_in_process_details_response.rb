class SignInProcessDetailsResponse < Api::Response
  attr_reader :transaction_entity_id
  validates :transaction_entity_id, presence: true

  def initialize(hash)
    @transaction_entity_id = hash["requestIssuerId"]
  end
end
