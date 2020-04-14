module Display
  ViewableEidasScheme = Struct.new(
    :scheme,
    :display_data,
    :logo_path,
  ) do
    delegate :simple_id, to: :scheme
    delegate :display_name, to: :display_data
    delegate :country_simple_id, to: :display_data

    def viewable?
      true
    end
  end
end
