class SelectedProviderData < SimpleDelegator
  attr_reader :journey_type
  attr_reader :identity_provider

  def initialize(journey_type, identity_provider)
    super(identity_provider)

    @journey_type = journey_type
    @identity_provider = identity_provider
  end

  def is_selected_country?
    @journey_type == JourneyType::EIDAS
  end

  def is_selected_verify_idp?
    @journey_type == JourneyType::VERIFY
  end

  def as_json(options = nil)
    { journey_type: @journey_type.as_json(options), identity_provider: @identity_provider.as_json(options) }
  end

  def self.from_session(object)
    return object if object.is_a? SelectedProviderData

    new(object["journey_type"], object["identity_provider"]) if object.is_a? Hash
  end
end
