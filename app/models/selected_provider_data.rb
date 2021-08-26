class SelectedProviderData < SimpleDelegator
  attr_reader :identity_provider

  def initialize(identity_provider)
    super(identity_provider)
    @identity_provider = identity_provider
  end

  def as_json(options = nil)
    { identity_provider: @identity_provider.as_json(options) }
  end

  def self.from_session(object)
    return object if object.is_a? SelectedProviderData

    new(object["identity_provider"]) if object.is_a? Hash
  end
end
