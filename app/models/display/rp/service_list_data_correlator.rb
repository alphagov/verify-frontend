module Display
  module Rp
    class ServiceListDataCorrelator
      Transaction = Struct.new(:name, :loa, :taxon, :serviceId)

      def initialize(translator, rps_name_homepage)
        @translator = translator
        @rps_name_homepage = rps_name_homepage
      end

      def correlate(data)
        filter_transactions(data, @rps_name_homepage).map do |transaction|
          Transaction.new(translate_name(transaction), transaction.fetch('loaList').min,
            translate_taxon(transaction), transaction.fetch('entityId'))
        end
      rescue KeyError => e
        Rails.logger.error e
        []
      end

    private

      def translate_name(transaction)
        simple_id = transaction.fetch('simpleId')
        @translator.translate("rps.#{simple_id}.name")
      end

      def filter_transactions(transactions, simple_ids)
        transactions = simple_ids.map do |simple_id|
          transactions.select { |tx| tx['simpleId'] == simple_id }
        end
        transactions.flatten
      end

      def translate_taxon(transaction)
        simple_id = transaction.fetch('simpleId')
        @translator.translate("rps.#{simple_id}.taxon_name")
      rescue Display::FederationTranslator::TranslationError
        @other_services_translation
      end
    end
  end
end
