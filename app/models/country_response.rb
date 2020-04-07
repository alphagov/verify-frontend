class CountryResponse < Api::Response
  attr_reader :countries
  validate :consistent_countries

  def initialize(response)
    @countries = response.map { |country| Country.from_api(country) }
  end

  def consistent_countries
    return if @countries.empty?

    if @countries.none?(&:valid?)
      errors.add(:countries, "are malformed")
    end
  end
end
