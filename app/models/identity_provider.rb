class IdentityProvider
  include ActiveModel::Model

  attr_reader :simple_id, :entity_id, :levels_of_assurance, :authentication_enabled, :provide_authentication_until, :provide_registration_until, :unavailable
  validates_presence_of :simple_id, :entity_id, :levels_of_assurance

  def initialize(hash)
    @simple_id = hash["simpleId"]
    @entity_id = hash["entityId"]
    @levels_of_assurance = hash["levelsOfAssurance"]
    @authentication_enabled = hash.fetch("authenticationEnabled", true)
    @provide_authentication_until = hash.fetch("provideAuthenticationUntil", true)
    @unavailable = hash.fetch("temporarilyUnavailable", false)
    @provide_registration_until = DateTime.parse(hash["provideRegistrationUntil"]) unless hash["provideRegistrationUntil"].nil?
  end

  def ==(other)
    if other.is_a?(IdentityProvider)
      simple_id == other.simple_id &&
        entity_id == other.entity_id &&
        levels_of_assurance == other.levels_of_assurance &&
        authentication_enabled == other.authentication_enabled &&
        unavailable == other.unavailable
    else
      super
    end
  end

  alias_method :eql?, :==

  def hash
    simple_id.hash + entity_id.hash + levels_of_assurance.hash + authentication_enabled.hash + unavailable.hash
  end

  def self.from_session(object)
    return object if object.is_a? IdentityProvider

    if object.is_a?(Hash) || (object.is_a?(SelectedProviderData) && object.is_selected_verify_idp?)
      new("simpleId" => object["simple_id"],
          "entityId" => object["entity_id"],
          "levelsOfAssurance" => object["levels_of_assurance"],
          "authenticationEnabled" => object["authentication_enabled"],
          "temporarilyUnavailable" => object["unavailable"])
    end
  end
end
