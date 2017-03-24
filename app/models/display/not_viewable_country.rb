module Display
  NotViewableCountry = Struct.new(:country) do
    delegate :entity_id, to: :country

    def viewable?
      false
    end
  end
end
