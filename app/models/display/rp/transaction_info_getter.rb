module Display
  module Rp
    class TransactionInfoGetter
      def initialize(session_proxy, repository)
        @session_proxy = session_proxy
        @repository = repository
      end

      def get_info(cookie_jar, session)
        repository.fetch(transaction_simple_id(cookie_jar, session))
      end

      def transaction_simple_id(cookie_jar, session)
        simple_id = session['transaction_simple_id']
        if simple_id.nil?
          federation_info = session_proxy.federation_info_for_session(cookie_jar)
          federation_info.transaction_simple_id
        else
          simple_id
        end
      end

    private

      attr_reader :session_proxy, :repository
    end
  end
end
