module Display
  module Rp
    class TransactionLister
      def initialize(proxy, correlator)
        @proxy = proxy
        @correlator = correlator
      end

      #correlated_data, property_to_filer
      def list()
        @correlator.correlate(@proxy.transactions)
      rescue StandardError => e
        Rails.logger.error e
        NoTransactions.new
      end

      class NoTransactions
        def name_homepage
          []
        end

        def name_only
          []
        end

        def any?
          false
        end
      end
    end
  end
end
