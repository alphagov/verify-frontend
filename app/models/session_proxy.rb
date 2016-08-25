require 'pathname'

class SessionProxy
  include SessionEndpoints

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
    SessionResponse.validated_response(response)
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

    @api_client.put(select_idp_endpoint(session_id), body)
  end

  def idp_authn_request(session_id)
    response = @api_client.get(
      idp_authn_request_endpoint(session_id),
      headers: x_forwarded_for,
    )
    OutboundSamlMessage.validated_response(response)
  end

  def idp_authn_response(session_id, saml_response, relay_state)
    body = {
      PARAM_RELAY_STATE => relay_state,
      PARAM_SAML_RESPONSE => saml_response,
      PARAM_ORIGINATING_IP => originating_ip
    }
    response = @api_client.put(session_endpoint(session_id, IDP_AUTHN_RESPONSE_SUFFIX), body)
    IdpAuthnResponse.validated_response(response)
  end

  def matching_outcome(session_id)
    response = @api_client.get(session_endpoint(session_id, MATCHING_OUTCOME_SUFFIX))
    MatchingOutcomeResponse.validated_response(response).outcome
  end

  def response_for_rp(session_id)
    response = @api_client.get(session_endpoint(session_id, RESPONSE_FOR_RP_SUFFIX),
                               headers: x_forwarded_for)
    ResponseForRp.validated_response(response)
  end

  def error_response_for_rp(session_id)
    response = @api_client.get(session_endpoint(session_id, ERROR_RESPONSE_FOR_RP_SUFFIX),
                               headers: x_forwarded_for)
    ResponseForRp.validated_response(response)
  end

  def cycle_three_attribute_name(session_id)
    response = @api_client.get(session_endpoint(session_id, CYCLE_THREE_SUFFIX))
    CycleThreeAttributeResponse.validated_response(response).name
  end

  def submit_cycle_three_value(session_id, value)
    body = {
      PARAM_CYCLE_THREE_VALUE => value,
      PARAM_ORIGINATING_IP => originating_ip
    }
    @api_client.post(session_endpoint(session_id, CYCLE_THREE_SUFFIX), body, {}, 200)
  end

  def cycle_three_cancel(session_id)
    @api_client.post(session_endpoint(session_id, CYCLE_THREE_CANCEL_SUFFIX), nil, {}, 200)
  end

private

  def federation_info_for_session(session_id)
    response = @api_client.get(session_endpoint(session_id, FEDERATION_INFO_SUFFIX))
    FederationInfoResponse.validated_response(response)
  end
end
