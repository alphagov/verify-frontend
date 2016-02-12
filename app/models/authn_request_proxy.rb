
class AuthnRequestProxy
  PATH = "/SAML2/SSO"
  PARAM_SAML_REQUEST = "samlRequest"
  PARAM_RELAY_STATE = "relayState"

  def initialize(api_client)
    @api_client = api_client
  end

  def proxy(saml_request, relay_state)
    body = {
        PARAM_SAML_REQUEST => saml_request,
        PARAM_RELAY_STATE => relay_state
    }
    @api_client.post(PATH, body)
  end
end
