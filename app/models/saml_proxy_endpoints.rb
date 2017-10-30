module SamlProxyEndpoints
  COUNTRY_AUTHN_RESPONSE_ENDPOINT = '/SAML2/SSO/API/RECEIVER/EidasResponse/POST'.freeze
  IDP_AUTHN_RESPONSE_ENDPOINT = '/SAML2/SSO/API/RECEIVER/Response/POST'.freeze

  PARAM_SAML_REQUEST = 'samlRequest'.freeze
  PARAM_RELAY_STATE = 'relayState'.freeze
  PARAM_SAML_RESPONSE = 'samlResponse'.freeze
  PARAM_IP_SEEN_BY_FRONTEND = 'principalIpAsSeenByFrontend'.freeze
  RESPONSE_FOR_RP_PATH = '/SAML2/SSO/API/SENDER/RESPONSE'.freeze
  ERROR_RESPONSE_FOR_RP_PATH = '/SAML2/SSO/API/SENDER/ERROR_RESPONSE'.freeze

  def response_for_rp_endpoint(session_id)
    session_id_query_parameter = { sessionId: session_id }.to_query
    RESPONSE_FOR_RP_PATH + "?#{session_id_query_parameter}"
  end

  def error_response_for_rp_endpoint(session_id)
    session_id_query_parameter = { sessionId: session_id }.to_query
    ERROR_RESPONSE_FOR_RP_PATH + "?#{session_id_query_parameter}"
  end
end
