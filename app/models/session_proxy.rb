
class SessionProxy
  PATH = "/session"
  IDP_PATH = "/session/idps"
  PARAM_SAML_REQUEST = "samlRequest"
  PARAM_RELAY_STATE = "relayState"
  PARAM_ORIGINATING_IP = "originatingIp"

  def initialize(api_client)
    @api_client = api_client
  end

  def create_session(saml_request, relay_state, x_forwarded_for)
    body = {
        PARAM_SAML_REQUEST => saml_request,
        PARAM_RELAY_STATE => relay_state,
        PARAM_ORIGINATING_IP => x_forwarded_for
    }
    @api_client.post(PATH, body)
  end

  def idps_for_session(cookies)
    session_cookie_names = CookieNames.session_cookies
    session_cookies = cookies.select { |name, _| session_cookie_names.include?(name) }.to_h
    @api_client.get(IDP_PATH, cookies: session_cookies)
  end
end
