module Display
  module Rp
    class ServiceListDataCorrelator
      Transaction = Struct.new(:name, :loa, :serviceCategory, :serviceId, :simpleId)

      def initialize(rp_display_repository)
        @rp_display_repository = rp_display_repository
      end

      def correlate(transactions)
        transactions.map do |transaction|
          transaction.symbolize_keys!
          simple_id = transaction.fetch(:simpleId)
          display_data = @rp_display_repository.get_translations(simple_id)
          Transaction.new(display_data.name, transaction.fetch(:loaList).min,
                          display_data.taxon, transaction.fetch(:entityId), simple_id)
        end
      rescue KeyError => e
        Rails.logger.error e
        []
      end
    end
  end
end
