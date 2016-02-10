
class AuthnRequestProxy
  PATH = "/SAML2/SSO"
  def initialize(api_client)
    @api_client = api_client
  end

  def proxy(saml_request, relay_state)
    body = {
        'saml_request' => saml_request,
        'relay_state' => relay_state
    }
    @api_client.post(PATH, body)
  end
end
