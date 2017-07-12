module Display
  ViewableIdentityProvider = Struct.new(
    :identity_provider,
    :display_data,
    :logo_path,
    :white_logo_path,
  ) do
    delegate :entity_id, to: :identity_provider
    delegate :simple_id, to: :identity_provider
    delegate :model_name, to: :identity_provider
    delegate :to_key, to: :identity_provider
    delegate :display_name, :about_content, :requirements, :special_no_docs_instructions, :no_docs_requirement, :contact_details, :interstitial_question, :interstitial_explanation, :mobile_app_installation, :tagline, to: :display_data

    def viewable?
      true
    end
  end
end
