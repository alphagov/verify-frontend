module Display
  module Idp
    DisplayData = Struct.new(:entity_id, :display_name, :logo_path, :white_logo_path)

    class DisplayDataCorrelator
      def initialize(translator, logo_directory, white_logo_directory)
        @translator = translator
        @logo_directory = logo_directory
        @white_logo_directory = white_logo_directory
      end

      def correlate(idp_list)
        idp_list.map { |idp| correlate_display_data(idp) }.reject(&:nil?)
      end

    private

      def correlate_display_data(idp)
        simple_id = idp['simpleId']
        key = "idps.#{simple_id}.name"
        logo_path = File.join(@logo_directory, "#{simple_id}.png")
        white_logo_path = File.join(@white_logo_directory, "#{simple_id}.png")
        name = @translator.translate(key)
        DisplayData.new(idp.fetch('entityId'), name, logo_path, white_logo_path)
      rescue FederationTranslator::TranslationError => e
        Rails.logger.error(e)
        nil
      end
    end
  end
end
