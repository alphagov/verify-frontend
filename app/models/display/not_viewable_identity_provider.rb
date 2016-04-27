module Display
  NotViewableIdentityProvider = Struct.new(:identity_provider) do
    delegate :entity_id, to: :identity_provider

    def viewable?
      false
    end
  end
end
