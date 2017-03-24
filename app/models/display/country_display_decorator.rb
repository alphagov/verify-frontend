module Display
  class CountryDisplayDecorator
    def initialize(repository)
      @repository = repository
    end

    def decorate_collection(country_list)
      country_list.map { |country| correlate_display_data(country) }.select(&:viewable?)
    end

    def decorate(country)
      correlate_display_data(country)
    end

  private

    def correlate_display_data(country)
      return not_viewable(country) unless !country.nil? && country.enabled == true
      simple_id = country.simple_id
      display_data = @repository.fetch(simple_id.to_s.downcase)
      ViewableCountry.new(country, display_data)
    rescue KeyError => e
      Rails.logger.error(e)
      not_viewable(country)
    end

    def not_viewable(country)
      NotViewableCountry.new(country)
    end
  end
end
