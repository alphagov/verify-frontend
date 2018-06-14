module Display
  NotViewableScheme = Struct.new(:scheme) do
    delegate :country_simple_id, to: :scheme
    delegate :display_name, to: :scheme

    def viewable?
      false
    end
  end
end
