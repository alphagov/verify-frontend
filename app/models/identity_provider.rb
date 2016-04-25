class IdentityProvider
  include ActiveModel::Model

  attr_reader :simple_id, :entity_id
  validates_presence_of :simple_id, :entity_id

  def initialize(hash)
    @simple_id = hash['simple_id']
    @entity_id = hash['entity_id']
  end

  def self.from_api(hash)
    new(
      'simple_id' => hash['simpleId'],
      'entity_id' => hash['entityId']
    )
  end
end
