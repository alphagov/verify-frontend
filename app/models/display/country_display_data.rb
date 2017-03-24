module Display
  class CountryDisplayData < DisplayData
    def prefix
      "countries"
    end

    content :name

    alias_method :display_name, :name
  end
end
