class SelectIdpResponse
  include ActiveModel::Model

  attr_reader :encrypted_entity_id
  validates_presence_of :encrypted_entity_id

  def initialize(hash)
    @encrypted_entity_id = hash['encryptedEntityId']
  end
end