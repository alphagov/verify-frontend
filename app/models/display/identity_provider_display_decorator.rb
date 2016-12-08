module Display
  class IdentityProviderDisplayDecorator
    def initialize(repository, logo_directory, white_logo_directory)
      @repository = repository
      @logo_directory = logo_directory
      @white_logo_directory = white_logo_directory
    end

    def decorate_collection(idp_list)
      # We need to randomise the order of IDPs so that it satisfies the need for us to be unbiased in displaying the IDPs.
      idp_list.map { |idp| correlate_display_data(idp) }.select(&:viewable?).shuffle
    end

    def decorate_collection_with_ranking(idp_list, ranking)
      decorate_collection(idp_list).sort_by { |idp| ranking.rank_idp(idp.simple_id) }
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
