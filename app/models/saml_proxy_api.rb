class SamlProxyApi
  include SamlProxyEndpoints

  def initialize(api_client, originating_ip_store)
    @api_client = api_client
    @originating_ip_store = originating_ip_store
  end

  def originating_ip
    @originating_ip_store.get
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
end
