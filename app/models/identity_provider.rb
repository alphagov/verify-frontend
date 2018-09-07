class IdentityProvider
  include ActiveModel::Model

  attr_reader :simple_id, :entity_id, :levels_of_assurance
  validates_presence_of :simple_id, :entity_id, :levels_of_assurance

  def initialize(hash)
    @simple_id = hash['simpleId']
    @entity_id = hash['entityId']
    @levels_of_assurance = hash['levelsOfAssurance']
  end

  def ==(other)
    if other.is_a?(IdentityProvider)
      self.simple_id == other.simple_id &&
        self.entity_id == other.entity_id &&
        self.levels_of_assurance == other.levels_of_assurance
    else
      super
    end
  end

  alias_method :eql?, :==

  def hash
    simple_id.hash + entity_id.hash + levels_of_assurance.hash
  end

  def self.from_session(object)
    return object if object.is_a? IdentityProvider
    if object.is_a?(Hash) || (object.is_a?(SelectedProviderData) && object.is_selected_verify_idp?)
      new('simpleId' => object['simple_id'], 'entityId' => object['entity_id'], 'levelsOfAssurance' => object['levels_of_assurance'])
    end
  end
end
