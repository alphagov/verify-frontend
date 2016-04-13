module Display
  module Rp
    class TransactionInfoGetter
      def initialize(session_proxy, repository)
        @session_proxy = session_proxy
        @repository = repository
      end

      def get_info(cookie_jar)
        federation_info = session_proxy.federation_info_for_session(cookie_jar)
        repository.fetch(federation_info.transaction_simple_id)
      end

    private

      attr_reader :session_proxy, :repository
    end
  end
end
