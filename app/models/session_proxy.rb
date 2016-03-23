
class SessionProxy
  PATH = "/session"
  FEDERATION_INFO_PATH = "#{PATH}/federation"
  SELECT_IDP_PATH = "#{PATH}/select-idp"
  IDP_AUTHN_REQUEST_PATH = "#{PATH}/idp-authn-request"
  PARAM_SAML_REQUEST = "samlRequest"
  PARAM_RELAY_STATE = "relayState"
  PARAM_ORIGINATING_IP = "originatingIp"
  PARAM_ENTITY_ID = 'entityId'

  def initialize(api_client, originating_ip_store)
    @api_client = api_client
    @originating_ip_store = originating_ip_store
  end

  def originating_ip
    @originating_ip_store.get
  end

  def create_session(saml_request, relay_state)
    body = {
        PARAM_SAML_REQUEST => saml_request,
        PARAM_RELAY_STATE => relay_state,
        PARAM_ORIGINATING_IP => originating_ip
    }
    @api_client.post(PATH, body)
  end

  def federation_info_for_session(cookies)
    session_cookies = select_cookies(cookies, CookieNames.session_cookies)
    response = @api_client.get(FEDERATION_INFO_PATH, cookies: session_cookies)
    FederationInfoResponse.new(response || {}).tap { |message|
      raise_if_invalid(message)
    }
  end

  def select_cookies(cookies, allowed_cookie_names)
    cookies.select { |name, _| allowed_cookie_names.include?(name) }.to_h
  end

  def select_idp(cookies, entity_id)
    body = {
        PARAM_ENTITY_ID => entity_id,
        PARAM_ORIGINATING_IP => originating_ip
    }
    response = @api_client.put(SELECT_IDP_PATH, body, cookies: select_cookies(cookies, CookieNames.session_cookies))
    SelectIdpResponse.new(response || {}).tap { |message|
      raise_if_invalid(message)
    }
  end

  def idp_authn_request(cookies)
    response = @api_client.get(IDP_AUTHN_REQUEST_PATH, cookies: select_cookies(cookies, CookieNames.all_cookies), params: { PARAM_ORIGINATING_IP => originating_ip })
    OutboundSamlMessage.new(response || {}).tap { |message|
      raise_if_invalid(message)
    }
  end

  def raise_if_invalid(response)
    raise ModelError, response.errors.full_messages.join(', ') unless response.valid?
  end

  ModelError = Class.new(StandardError)
end
