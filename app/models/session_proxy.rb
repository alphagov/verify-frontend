
class SessionProxy
  PATH = "/session"
  PARAM_SAML_REQUEST = "samlRequest"
  PARAM_RELAY_STATE = "relayState"
  PARAM_ORIGINATING_IP = "originatingIp"

  def initialize(api_client)
    @api_client = api_client
  end

  def proxy(saml_request, relay_state, x_forwarded_for)
    body = {
        PARAM_SAML_REQUEST => saml_request,
        PARAM_RELAY_STATE => relay_state,
        PARAM_ORIGINATING_IP => x_forwarded_for
    }
    @api_client.post(PATH, body)
  end
end
