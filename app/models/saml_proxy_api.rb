class SamlProxyApi
  include SamlProxyEndpoints

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

  def forward_country_authn_response(relay_state, saml_response)
    body = {
        PARAM_SAML_REQUEST => saml_response,
        PARAM_RELAY_STATE => relay_state,
        PARAM_IP_SEEN_BY_FRONTEND => originating_ip
    }
    response = @api_client.post(COUNTRY_AUTHN_RESPONSE_ENDPOINT, body)
    CountryAuthnResponse.validated_response(response)
  end

  def response_for_rp(session_id)
    response = @api_client.get(response_for_rp_endpoint(session_id), headers: x_forwarded_for)
    ResponseForRp.validated_response(response)
  end

  def error_response_for_rp(session_id)
    response = @api_client.get(error_response_for_rp_endpoint(session_id), headers: x_forwarded_for)
    ResponseForRp.validated_response(response)
  end

  def idp_authn_response(session_id, saml_response)
    body = {
        PARAM_RELAY_STATE => session_id,
        PARAM_SAML_REQUEST => saml_response,
        PARAM_IP_SEEN_BY_FRONTEND => originating_ip
    }
    response = @api_client.post(IDP_AUTHN_RESPONSE_ENDPOINT, body)

    IdpAuthnResponse.validated_response(response)
  end

  def authn_request(session_id)
    response = @api_client.get(
        authn_request_endpoint(session_id),
        headers: x_forwarded_for,
    )
    OutboundSamlMessage.validated_response(response)
  end
end
