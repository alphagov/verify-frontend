module Display
  class CountryDisplayDecorator
    def initialize(repository, flags_directory)
      @repository = repository
      @flags_directory = flags_directory
    end

    def decorate_collection(country_list, scheme_map)
      country_list.map { |country| correlate_display_data(country, scheme_map[country.simple_id]) }
          .select(&:viewable?).sort_by(&:display_name)
    end

    def decorate(country, scheme_map)
      correlate_display_data(country, scheme_map[country.simple_id])
    end

  private

    def correlate_display_data(country, schemes)
      return not_viewable(country) unless !country.nil? && country.enabled == true && !schemes.nil? && !schemes.empty?
      simple_id = country.simple_id
      flag_path = File.join(@flags_directory, "#{simple_id}.svg")
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
