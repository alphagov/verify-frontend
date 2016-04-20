module Display
  module Idp
    DisplayData = Struct.new(:identity_provider, :display_name, :logo_path, :white_logo_path, :about_content) do
      delegate :entity_id, to: :identity_provider
      delegate :simple_id, to: :identity_provider
    end

    class DisplayDataCorrelator
      def initialize(translator, logo_directory, white_logo_directory)
        @translator = translator
        @logo_directory = logo_directory
        @white_logo_directory = white_logo_directory
      end

      def correlate(idp_list)
        # We need to randomise the order of IDPs so that it satisfies the need for us to be unbiased in displaying the IDPs.
        idp_list.map { |idp| correlate_display_data(idp) }.reject(&:nil?).shuffle
      end

    private

      def correlate_display_data(idp)
        simple_id = idp.simple_id
        logo_path = File.join(@logo_directory, "#{simple_id}.png")
        white_logo_path = File.join(@white_logo_directory, "#{simple_id}.png")
        name = @translator.translate("idps.#{simple_id}.name")
        about = @translator.translate("idps.#{simple_id}.about")
        DisplayData.new(idp, name, logo_path, white_logo_path, about)
      rescue FederationTranslator::TranslationError => e
        Rails.logger.error(e)
        nil
      end
    end
  end
end
