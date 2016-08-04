module Display
  module Rp
    class TransactionLister
      def initialize(proxy, correlator)
        @proxy = proxy
        @correlator = correlator
      end

      def list(session)
        @correlator.correlate(@proxy.transactions(session))
      rescue StandardError => e
        Rails.logger.error e
        NoTransactions.new
      end

      class NoTransactions
        def public
          []
        end

        def private
          []
        end

        def any?
          false
        end
      end
    end
  end
end
