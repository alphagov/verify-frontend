module Display
  class CountryDisplayDecorator
    def initialize(repository, flags_directory)
      @repository = repository
      @flags_directory = flags_directory
    end

    def decorate_collection(country_list)
      country_list.map { |country| correlate_display_data(country) }
          .select(&:viewable?).sort_by(&:display_name)
    end

    def decorate(country)
      correlate_display_data(country)
    end

  private

    def correlate_display_data(country)
      schemes = EIDAS_SCHEME_DISPLAY_DECORATOR.decorated_schemes_for_country(country.simple_id)
      return not_viewable(country) if country.nil? || country.enabled == false || schemes.nil? || schemes.empty?
      simple_id = country.simple_id
      flag_path = File.join(@flags_directory, "#{simple_id.to_s.downcase}.svg")
      display_data = @repository.fetch(simple_id.to_s.downcase)
      ViewableCountry.new(country, display_data, flag_path, schemes)
    rescue KeyError => e
      Rails.logger.error(e)
      not_viewable(country)
    end

    def not_viewable(country)
      NotViewableCountry.new(country)
    end
  end
end
