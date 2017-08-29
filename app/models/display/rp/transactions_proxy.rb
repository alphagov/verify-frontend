module Display
  module Rp
    class TransactionsProxy
      def initialize(api_client)
        @api_client = api_client
      end

      def transactions
        @api_client.get('/config/transactions/enabled')
      end
    end
  end
end
