class FederationInfoResponse
  include ActiveModel::Model

  attr_reader :idps, :transaction_simple_id, :transaction_entity_id
  validates_presence_of :transaction_entity_id
  validates_presence_of :transaction_simple_id
  validate :consistent_idps

  def initialize(hash)
    @idps = hash['idps'].map { |idp| IdentityProvider.new(idp) }
    @transaction_simple_id = hash['transactionSimpleId']
    @transaction_entity_id = hash['transactionEntityId']
  end

  def consistent_idps
    return if @idps.empty?
    if @idps.none?(&:valid?)
      errors.add(:identity_providers, 'are malformed')
    end
  end
end
