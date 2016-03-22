module Display
  module Idp
    DisplayData = Struct.new(:entity_id, :display_name, :logo_path)

    class DisplayDataCorrelator
      def initialize(translator)
        @translator = translator
      end

      def correlate(idp_list, logo_directory)
        idp_list.map { |idp| correlate_display_data(idp, logo_directory) }.reject(&:nil?)
      end

    private

      def correlate_display_data(idp, logo_directory)
        simple_id = idp['simpleId']
        key = "idps.#{simple_id}.name"
        logo_for_simple_id = File.join(logo_directory, "#{simple_id}.png")
        name = @translator.translate(key)
        DisplayData.new(idp.fetch('entityId'), name, logo_for_simple_id)
      rescue FederationTranslator::TranslationError => e
        Rails.logger.error(e)
        nil
      end
    end
  end
end
