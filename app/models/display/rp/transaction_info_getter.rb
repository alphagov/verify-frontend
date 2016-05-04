module Display
  module Rp
    class TransactionInfoGetter
      def initialize(session_proxy, repository)
        @session_proxy = session_proxy
        @repository = repository
      end

      def get_info(session)
        simple_id = session['transaction_simple_id']
        if simple_id.nil?
          raise StandardError, 'No transaction simple id in session'
        end
        repository.fetch(simple_id)
      end

    private

      attr_reader :session_proxy, :repository
    end
  end
end
