module Display
  ViewableIdentityProvider = Struct.new(:identity_provider, :display_name, :logo_path, :white_logo_path, :about_content) do
    delegate :entity_id, to: :identity_provider
    delegate :simple_id, to: :identity_provider
    delegate :model_name, to: :identity_provider
    delegate :to_key, to: :identity_provider
  end
end
