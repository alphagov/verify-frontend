module Display
  module Rp
    class TransactionTaxonCorrelator
      def correlate(transactions)
        TransactionList.from(transactions)
          .select_enabled
          .with_display_data
          .sort
          .group_by_taxon
          .sort
      end
    end
  end
end
