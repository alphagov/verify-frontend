SelectedProviderData = Struct.new(
  :journey_type,
  :identity_provider
) do

  def self.from_session(object)
    return object if object.is_a? SelectedProviderData
    new(object['journey_type'], object['identity_provider']) if object.is_a? Hash
  end
end
