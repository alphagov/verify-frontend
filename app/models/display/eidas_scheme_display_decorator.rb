module Display
  class EidasSchemeDisplayDecorator
    def initialize(repository, logos_directory)
      @repository = repository
      @logos_directory = logos_directory
      @schemes_by_country = @repository.values.group_by(&:country_simple_id)
    end

    def decorated_schemes_for_country(country_simple_id)
      decorate_collection(@schemes_by_country[country_simple_id])
    end

    def decorate_collection(scheme_list)
      return [] if scheme_list.nil? || scheme_list.empty?
      scheme_list.map { |scheme| correlate_display_data(scheme) }.select(&:viewable?)
          .sort_by { |scheme| scheme.display_name.downcase }
    end

    def decorate(scheme)
      correlate_display_data(scheme)
    end

  private

    def correlate_display_data(scheme)
      return not_viewable(scheme) if scheme.nil?
      simple_id = scheme.simple_id
      logo_path = File.join(@logos_directory, "#{simple_id}.png")
      display_data = @repository.fetch(simple_id.to_s.downcase)
      ViewableEidasScheme.new(scheme, display_data, logo_path)
    rescue KeyError => e
      Rails.logger.error(e)
      not_viewable(scheme)
    end

    def not_viewable(scheme)
      NotViewableScheme.new(scheme)
    end
  end
end
