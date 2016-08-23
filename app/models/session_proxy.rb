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

  def identity_providers(session_id)
    federation_info_for_session(session_id).idps
  end

  def select_cookies(cookies, allowed_cookie_names)
    cookies.select { |name, _| allowed_cookie_names.include?(name) }.to_h
  end

  def select_idp(session_id, entity_id, registration = false)
    body = {
      PARAM_ENTITY_ID => entity_id,
      PARAM_ORIGINATING_IP => originating_ip,
      PARAM_REGISTRATION => registration
    }

    @api_client.put(SELECT_IDP_PATH, body, cookies: session_cookie(session_id))
  end

  def idp_authn_request(session_id)
    response = @api_client.get(
      IDP_AUTHN_REQUEST_PATH,
      cookies: session_cookie(session_id),
      headers: x_forwarded_for,
    )
    OutboundSamlMessage.new(response || {}).tap(&:validate)
  end

  def idp_authn_response(session_id, saml_response, relay_state)
    body = {
      PARAM_RELAY_STATE => relay_state,
      PARAM_SAML_RESPONSE => saml_response,
      PARAM_ORIGINATING_IP => originating_ip
    }
    response = @api_client.put(IDP_AUTHN_RESPONSE_PATH, body, cookies: session_cookie(session_id))
    IdpAuthnResponse.new(response || {}).tap(&:validate)
  end

  def matching_outcome(session_id)
    response = @api_client.get(MATCHING_OUTCOME_PATH, cookies: session_cookie(session_id))
    MatchingOutcomeResponse.new(response || {}).tap(&:validate).outcome
  end

  def response_for_rp(session_id)
    response = @api_client.get(RESPONSE_FOR_RP_PATH,
                               headers: x_forwarded_for,
                               cookies: session_cookie(session_id))
    ResponseForRp.new(response || {}).tap(&:validate)
  end

  def error_response_for_rp(session_id)
    response = @api_client.get(ERROR_RESPONSE_FOR_RP_PATH,
                               headers: x_forwarded_for,
                               cookies: session_cookie(session_id))
    ResponseForRp.new(response || {}).tap(&:validate)
  end

  def cycle_three_attribute_name(session_id)
    response = @api_client.get(CYCLE_THREE_PATH,
                               cookies: session_cookie(session_id))
    CycleThreeAttributeResponse.new(response || {}).tap(&:validate).name
  end

  def submit_cycle_three_value(session_id, value)
    body = {
      PARAM_CYCLE_THREE_VALUE => value,
      PARAM_ORIGINATING_IP => originating_ip
    }
    options = {
      cookies: session_cookie(session_id),
    }
    @api_client.post(CYCLE_THREE_PATH, body, options, 200)
  end

  def cycle_three_cancel(session_id)
    options = {
      cookies: session_cookie(session_id)
    }
    @api_client.post(CYCLE_THREE_CANCEL_PATH, nil, options, 200)
  end

private

  def session_cookie(session_id)
    {
      CookieNames::SESSION_ID_COOKIE_NAME => session_id,
    }
  end

  def federation_info_for_session(session_id)
    response = @api_client.get(FEDERATION_INFO_PATH, cookies: session_cookie(session_id))
    FederationInfoResponse.new(response || {}).tap(&:validate)
  end
end
