
class SessionProxy
  PATH = "/session"
  IDP_PATH = "#{PATH}/idps"
  SELECT_IDP_PATH = "#{PATH}/select-idp"
  IDP_AUTHN_REQUEST_PATH = "#{PATH}/idp-authn-request"
  PARAM_SAML_REQUEST = "samlRequest"
  PARAM_RELAY_STATE = "relayState"
  PARAM_ORIGINATING_IP = "originatingIp"
  PARAM_ENTITY_ID = 'entityId'

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
    session_cookies = select_session_cookies(cookies)
    @api_client.get(IDP_PATH, cookies: session_cookies)
  end

  def select_session_cookies(cookies)
    session_cookie_names = CookieNames.session_cookies
    cookies.select { |name, _| session_cookie_names.include?(name) }.to_h
  end

  def select_idp(cookies, entity_id, originating_ip)
    body = {
        PARAM_ENTITY_ID => entity_id,
        PARAM_ORIGINATING_IP => originating_ip
    }
    @api_client.put(SELECT_IDP_PATH, body, cookies: select_session_cookies(cookies))
  end

  def idp_authn_request(cookies, originating_ip)
    @api_client.get(IDP_AUTHN_REQUEST_PATH, cookies: select_session_cookies(cookies), params: {PARAM_ORIGINATING_IP => originating_ip})
  end
end
