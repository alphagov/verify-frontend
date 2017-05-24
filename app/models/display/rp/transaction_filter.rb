module Display
  module Rp
    class TransactionFilter
      def filter_by_loa(transactions, loa)
        transaction_list = []
        transactions::values.each do |value|
          value.each do |transaction|
            if transaction.loa_list.min == loa
              transaction_list << transaction
            end
          end
        end
        transaction_list
      end
    end
  end
end
