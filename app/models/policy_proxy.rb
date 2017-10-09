class PolicyProxy
  include PolicyEndpoints

  def initialize(api_client, originating_ip_store)
    @api_client = api_client
    @originating_ip_store = originating_ip_store
  end

  def originating_ip
    @originating_ip_store.get
  end

  def select_idp(session_id, entity_id, registration = false)
    body = {
        PARAM_SELECTED_ENTITY_ID => entity_id,
        PARAM_PRINCIPAL_IP => originating_ip,
        PARAM_REGISTRATION => registration
    }

    @api_client.post(select_idp_endpoint(session_id), body, {})
  end

  def matching_outcome(session_id)
    response = @api_client.get(matching_outcome_endpoint(session_id))
    MatchingOutcomeResponse.validated_response(response).outcome
  end
end
