class IdentityProvider
  include ActiveModel::Model

  attr_reader :simple_id, :entity_id, :levels_of_assurance
  validates_presence_of :simple_id, :entity_id, :levels_of_assurance

  def initialize(hash)
    @simple_id = hash['simple_id']
    @entity_id = hash['entity_id']
    @levels_of_assurance = hash['levels_of_assurance']
  end

  def self.from_api(hash)
    new(
      'simple_id' => hash['simpleId'],
      'entity_id' => hash['entityId'],
      'levels_of_assurance' => hash['levelsOfAssurance']
    )
  end

  def self.from_session(object)
    return object if object.is_a? IdentityProvider
    return new(object) if object.is_a? Hash
  end
end
