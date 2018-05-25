module Display
  class IdentityProviderDisplayDecoratorVariant
    def initialize(repository, logo_directory, white_logo_directory)
      @repository = repository
      @logo_directory = logo_directory
      @white_logo_directory = white_logo_directory
    end

    def decorate_collection(idp_list)
      # We need to order the IDPs by the rating from fed config
      idps = idp_list.map { |idp| correlate_display_data(idp) }.select(&:viewable?)
      idps = idps.index_by(&:simple_id).values_at(*IDP_LOA1_ORDER) unless idps.empty? || IDP_LOA1_ORDER.empty?

      idps
    end

    def decorate(idp)
      correlate_display_data(idp)
    end

  private

    def correlate_display_data(idp)
      return not_viewable(idp) if idp.nil?
      simple_id = idp.simple_id
      logo_path = File.join(@logo_directory, "#{simple_id}.png")
      white_logo_path = File.join(@white_logo_directory, "#{simple_id}.png")
      display_data = @repository.fetch(simple_id)
      ViewableIdentityProvider.new(idp, display_data, logo_path, white_logo_path)
    rescue KeyError => e
      Rails.logger.error(e)
      not_viewable(idp)
    end

    def not_viewable(idp)
      NotViewableIdentityProvider.new(idp)
    end
  end
end
