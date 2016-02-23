module Display
  module Idp
    DisplayData = Struct.new(:entity_id, :display_name, :logo_path)

    class DisplayDataCorrelator
      def initialize(translator, logo_directory)
        @translator = translator
        @logo_directory = logo_directory
      end

      def correlate(idp_list)
        idp_list.map { |idp| correlate_display_data(idp) }.reject(&:nil?)
      end

      def correlate_display_data(idp)
        simple_id = idp['simpleId']
        key = "idps.#{simple_id}.name"
        logo = logo_for(simple_id)
        name = @translator.translate(key)
        DisplayData.new(idp.fetch('entityId'), name, logo)
      rescue FederationTranslator::TranslationError => e
        Rails.logger.error(e)
        nil
      end

      def logo_for(simple_id)
        File.join(@logo_directory, "#{simple_id}.png")
      end
    end
  end
end
