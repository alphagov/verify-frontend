class SessionProxy
  PATH = '/session'.freeze
  FEDERATION_INFO_PATH = "#{PATH}/federation".freeze
  SELECT_IDP_PATH = "#{PATH}/select-idp".freeze
  IDP_AUTHN_REQUEST_PATH = "#{PATH}/idp-authn-request".freeze
  IDP_AUTHN_RESPONSE_PATH = "#{PATH}/idp-authn-response".freeze
  SESSION_STATE_PATH = "#{PATH}/state".freeze
  MATCHING_OUTCOME_PATH = "#{PATH}/matching-outcome".freeze
  RESPONSE_FOR_RP_PATH = "#{PATH}/response-for-rp/success".freeze
  ERROR_RESPONSE_FOR_RP_PATH = "#{PATH}/response-for-rp/error".freeze
  CYCLE_THREE_PATH = "#{PATH}/cycle-three".freeze
  CYCLE_THREE_CANCEL_PATH = "#{CYCLE_THREE_PATH}/cancel".freeze
  PARAM_SAML_REQUEST = 'samlRequest'.freeze
  PARAM_SAML_RESPONSE = 'samlResponse'.freeze
  PARAM_RELAY_STATE = 'relayState'.freeze
  PARAM_ORIGINATING_IP = 'originatingIp'.freeze
  PARAM_ENTITY_ID = 'entityId'.freeze
  PARAM_REGISTRATION = 'registration'.freeze
  PARAM_CYCLE_THREE_VALUE = 'value'.freeze

  def initialize(api_client, originating_ip_store)
    @api_client = api_client
    @originating_ip_store = originating_ip_store
  end

  def originating_ip
    @originating_ip_store.get
  end

  def x_forwarded_for
    { 'X-Forwarded-For' => originating_ip }
  end

  def create_session(saml_request, relay_state)
    body = {
      PARAM_SAML_REQUEST => saml_request,
      PARAM_RELAY_STATE => relay_state,
      PARAM_ORIGINATING_IP => originating_ip
    }
    response = @api_client.post(PATH, body)
    SessionResponse.new(response || {}).tap(&:validate)
  end

  def identity_providers(cookies)
    federation_info_for_session(cookies).idps
  end

  def select_cookies(cookies, allowed_cookie_names)
    cookies.select { |name, _| allowed_cookie_names.include?(name) }.to_h
  end

  def select_idp(cookies, entity_id, registration = false)
    body = {
      PARAM_ENTITY_ID => entity_id,
      PARAM_ORIGINATING_IP => originating_ip,
      PARAM_REGISTRATION => registration
    }
    @api_client.put(SELECT_IDP_PATH, body, cookies: select_cookies(cookies, CookieNames.session_cookies))
  end

  def idp_authn_request(session, cookies)
    cookies = map_session_to_cookies(session, cookies)
    response = @api_client.get(
      IDP_AUTHN_REQUEST_PATH,
      cookies: select_cookies(cookies, CookieNames.all_cookies),
      headers: x_forwarded_for,
      params: { PARAM_ORIGINATING_IP => originating_ip }
    )
    OutboundSamlMessage.new(response || {}).tap(&:validate)
  end

  def idp_authn_response(cookies, saml_response, relay_state)
    body = {
      PARAM_RELAY_STATE => relay_state,
      PARAM_SAML_RESPONSE => saml_response,
      PARAM_ORIGINATING_IP => originating_ip
    }
    response = @api_client.put(IDP_AUTHN_RESPONSE_PATH, body, cookies: select_cookies(cookies, CookieNames.session_cookies))
    IdpAuthnResponse.new(response || {}).tap(&:validate)
  end

  def matching_outcome(cookies)
    response = @api_client.get(MATCHING_OUTCOME_PATH, cookies: select_cookies(cookies, CookieNames.session_cookies))
    MatchingOutcomeResponse.new(response || {}).tap(&:validate).outcome
  end

  def response_for_rp(cookies)
    response = @api_client.get(RESPONSE_FOR_RP_PATH,
                               headers: x_forwarded_for,
                               cookies: select_cookies(cookies, CookieNames.session_cookies))
    ResponseForRp.new(response || {}).tap(&:validate)
  end

  def error_response_for_rp(cookies)
    response = @api_client.get(ERROR_RESPONSE_FOR_RP_PATH,
                               headers: x_forwarded_for,
                               cookies: select_cookies(cookies, CookieNames.session_cookies))
    ResponseForRp.new(response || {}).tap(&:validate)
  end

  def cycle_three_attribute_name(cookies)
    response = @api_client.get(CYCLE_THREE_PATH,
                               cookies: select_cookies(cookies, CookieNames.session_cookies))
    CycleThreeAttributeResponse.new(response || {}).tap(&:validate).name
  end

  def submit_cycle_three_value(cookies, value)
    body = {
      PARAM_CYCLE_THREE_VALUE => value,
      PARAM_ORIGINATING_IP => originating_ip
    }
    options = {
      cookies: select_cookies(cookies, CookieNames.session_cookies),
    }
    @api_client.post(CYCLE_THREE_PATH, body, options, 200)
  end

  def cycle_three_cancel(cookies)
    options = {
      cookies: select_cookies(cookies, CookieNames.session_cookies),
    }
    @api_client.post(CYCLE_THREE_CANCEL_PATH, nil, options, 200)
  end

private

  def federation_info_for_session(cookies)
    session_cookies = select_cookies(cookies, CookieNames.session_cookies)
    response = @api_client.get(FEDERATION_INFO_PATH, cookies: session_cookies)
    FederationInfoResponse.new(response || {}).tap(&:validate)
  end
end
