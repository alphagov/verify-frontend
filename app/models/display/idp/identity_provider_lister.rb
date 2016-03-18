module Display
  module Idp
    class IdentityProviderLister
      def initialize(session_proxy, display_correlator)
        @session_proxy = session_proxy
        @display_correlator = display_correlator
      end

      def list(cookie_jar)
        idp_id_list = @session_proxy.idps_for_session(cookie_jar)
        # We need to randomise the order of IDPs so that it satisfies the need for us to be unbiased in displaying the IDPs.
        @display_correlator.correlate(idp_id_list.shuffle)
      end
    end
  end
end
