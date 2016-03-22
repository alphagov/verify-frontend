module Display
  module Federation
    class FederationInfoGetter
      def initialize(session_proxy, display_correlator)
        @session_proxy = session_proxy
        @display_correlator = display_correlator
      end

      def get_info(cookie_jar)
        federation_info = @session_proxy.federation_info_for_session(cookie_jar)
        # We need to randomise the order of IDPs so that it satisfies the need for us to be unbiased in displaying the IDPs.
        idp_display_data = @display_correlator.correlate(federation_info.idps.shuffle)

        { idp_display_data: idp_display_data, transaction_entity_id: federation_info.transaction_entity_id }
      end
    end
  end
end
