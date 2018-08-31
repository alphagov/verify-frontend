module Display
  module Rp
    class ServiceListDataCorrelator
      Transaction = Struct.new(:name, :loa, :serviceCategory, :serviceId)

      def initialize(rp_display_repository, rps_name_homepage)
        @rp_display_repository = rp_display_repository
        @rps_name_homepage = rps_name_homepage
      end

      def correlate(data)
        filter_transactions(data, @rps_name_homepage).map do |transaction|
          simple_id = transaction.fetch('simpleId')
          display_data = @rp_display_repository.get_translations(simple_id)
          Transaction.new(display_data.name, transaction.fetch('loaList').min,
                          display_data.taxon, transaction.fetch('entityId'))
        end
      rescue KeyError => e
        Rails.logger.error e
        []
      end

    private

      def filter_transactions(transactions, simple_ids)
        transactions = simple_ids.map do |simple_id|
          transactions.select { |tx| tx['simpleId'] == simple_id }
        end
        transactions.flatten
      end
    end
  end
end
