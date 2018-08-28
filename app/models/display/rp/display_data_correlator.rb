module Display
  module Rp
    class DisplayDataCorrelator
      Transactions = Struct.new(:name_homepage, :name_only) do
        def any?
          name_homepage.any? || name_only.any?
        end
      end
      Transaction = Struct.new(:name, :homepage, :loa_list)

      def initialize(rp_display_repository, rps_name_homepage, rps_name_only)
        @rp_display_repository = rp_display_repository
        @rps_name_homepage = rps_name_homepage
        @rps_name_only = rps_name_only
      end

      def correlate(data)
        transactions_name_homepage = filter_transactions(data, @rps_name_homepage).map do |transaction|
          name = translate_name(transaction)
          Transaction.new(name, transaction.fetch('serviceHomepage'), transaction.fetch('loaList'))
        end
        transactions_name_only = filter_transactions(data, @rps_name_only).map do |transaction|
          name = translate_name(transaction)
          Transaction.new(name, nil, transaction.fetch('loaList'))
        end
        Transactions.new(transactions_name_homepage, transactions_name_only)
      rescue KeyError => e
        Rails.logger.error e
        Transactions.new([], [])
      end

      def retrieve_current_service(data, service_name)
        current_service_transaction = data.select { |tx| tx['simpleId'] == service_name }
        translate_name(current_service_transaction[0])
      end

    private

      def translate_name(transaction)
        simple_id = transaction.fetch('simpleId')
        @rp_display_repository.get_translations(simple_id).name
      end

      def filter_transactions(transactions, simple_ids)
        simple_ids.map { |simple_id| transactions.select { |tx| tx['simpleId'] == simple_id } }.flatten
      end
    end
  end
end
