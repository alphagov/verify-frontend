module Display
  ViewableCountry = Struct.new(
    :country,
    :display_data,
    :flag_path,
    :schemes
  ) do
    delegate :entity_id, to: :country
    delegate :simple_id, to: :country
    delegate :model_name, to: :country
    delegate :to_key, to: :country
    delegate :display_name, to: :display_data

    def viewable?
      true
    end
  end
end
