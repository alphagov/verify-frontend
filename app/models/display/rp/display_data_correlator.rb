module Display
  module Rp
    class DisplayDataCorrelator
      Transactions = Struct.new(:transactions)
      Transaction = Struct.new(:name, :homepage, :loa_list)

      def initialize(rp_display_repository, relying_parties)
        @rp_display_repository = rp_display_repository
        @relying_parties = relying_parties
      end

      def correlate(data)
        transactions = filter_transactions(data).map do |transaction|
          name = translate_name(transaction)
          Transaction.new(name, transaction.fetch("serviceHomepage"), transaction.fetch("loaList"))
        end
        Transactions.new(transactions)
      rescue KeyError => e
        Rails.logger.error e
        Transactions.new([], [])
      end

    private

      def translate_name(transaction)
        simple_id = transaction.fetch("simpleId")
        @rp_display_repository.get_translations(simple_id).name
      end

      def filter_transactions(transactions)
        @relying_parties.map { |simple_id| transactions.select { |tx| tx["simpleId"] == simple_id } }.flatten
      end
    end
  end
end
