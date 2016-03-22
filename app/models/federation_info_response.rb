class FederationInfoResponse
  include ActiveModel::Model

  attr_reader :idps, :transaction_entity_id
  validates_presence_of :transaction_entity_id

  def initialize(hash)
    @idps = hash['idps']
    @transaction_entity_id = hash['transactionEntityId']
  end
end
