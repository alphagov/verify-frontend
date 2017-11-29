module SamlProxyEndpoints
  COUNTRY_AUTHN_RESPONSE_ENDPOINT = '/SAML2/SSO/API/RECEIVER/EidasResponse/POST'.freeze
  IDP_AUTHN_RESPONSE_ENDPOINT = '/SAML2/SSO/API/RECEIVER/Response/POST'.freeze
  NEW_SESSION_ENDPOINT = '/SAML2/SSO/API/RECEIVER'.freeze
  PARAM_SAML_REQUEST = 'samlRequest'.freeze
  PARAM_RELAY_STATE = 'relayState'.freeze
  PARAM_IP_SEEN_BY_FRONTEND = 'principalIpAsSeenByFrontend'.freeze
  RESPONSE_FOR_RP_PATH = '/SAML2/SSO/API/SENDER/RESPONSE'.freeze
  AUTHN_REQUEST_PATH = '/SAML2/SSO/API/SENDER/AUTHN_REQ'.freeze
  ERROR_RESPONSE_FOR_RP_PATH = '/SAML2/SSO/API/SENDER/ERROR_RESPONSE'.freeze

  def response_for_rp_endpoint(session_id)
    endpoint_with_session_id(RESPONSE_FOR_RP_PATH, session_id)
  end

  def error_response_for_rp_endpoint(session_id)
    endpoint_with_session_id(ERROR_RESPONSE_FOR_RP_PATH, session_id)
  end

  def authn_request_endpoint(session_id)
    endpoint_with_session_id(AUTHN_REQUEST_PATH, session_id)
  end

  def endpoint_with_session_id(path, session_id)
    session_id_query_parameter = { sessionId: session_id }.to_query
    path + "?#{session_id_query_parameter}"
  end

  def new_session_endpoint
    NEW_SESSION_ENDPOINT
  end
end
