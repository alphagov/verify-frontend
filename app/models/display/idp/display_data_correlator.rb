module Display
  module Idp
    DisplayData = Struct.new(:entity_id, :display_name)

    class DisplayDataCorrelator
      def initialize(translator)
        @translator = translator
      end

      def correlate(idp_list)
        idp_list.map { |idp| correlate_display_data(idp) }.reject(&:nil?)
      end

      def correlate_display_data(idp)
        key = "idps.#{idp['simpleId']}.name"
        name = @translator.translate(key)
        DisplayData.new(idp.fetch('entityId'), name)
      rescue FederationTranslator::TranslationError => e
        Rails.logger.error(e)
        nil
      end
    end
  end
end
