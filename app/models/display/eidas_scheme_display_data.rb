module Display
  class EidasSchemeDisplayData
    def initialize(simple_id, data)
      @simple_id = simple_id
      @country_simple_id = data["country_simple_id"]
      @name = data["name"]
    end

    attr_reader :simple_id
    attr_reader :country_simple_id
    attr_reader :name

    alias display_name name
  end
end
