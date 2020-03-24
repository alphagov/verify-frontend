class PolicyProxy
  include PolicyEndpoints

  def initialize(api_client, originating_ip_store)
    @api_client = api_client
    @originating_ip_store = originating_ip_store
  end

  def originating_ip
    @originating_ip_store.get
  end

  def get_sign_in_process_details(session_id)
    response = @api_client.get(sign_in_process_details_endpoint(session_id))
    SignInProcessDetailsResponse.validated_response(response)
  end

  def select_idp(session_id, entity_id, requested_loa, registration = false, analytics_session_id = nil, journey_type = nil, variant = nil)
    body = {
      PARAM_SELECTED_ENTITY_ID => entity_id,
      PARAM_PRINCIPAL_IP => originating_ip,
      PARAM_REGISTRATION => registration,
      PARAM_REQUESTED_LOA => requested_loa,
      PARAM_ANALYTICS_SESSION_ID => analytics_session_id,
      PARAM_JOURNEY_TYPE => journey_type,
      PARAM_VARIANT => variant
    }
    @api_client.post(select_idp_endpoint(session_id), body)
  end

  def matching_outcome(session_id)
    response = @api_client.get(matching_outcome_endpoint(session_id))
    MatchingOutcomeResponse.validated_response(response).outcome
  end

  def cycle_three_attribute_name(session_id)
    response = @api_client.get(cycle_three_endpoint(session_id))
    CycleThreeAttributeResponse.validated_response(response).name
  end

  def submit_cycle_three_value(session_id, value)
    body = {
      PARAM_CYCLE_3_INPUT => value,
      PARAM_PRINCIPAL_IP => originating_ip
    }
    @api_client.post(cycle_three_submit_endpoint(session_id), body)
  end

  def cycle_three_cancel(session_id)
    @api_client.post(cycle_three_cancel_endpoint(session_id), nil)
  end

  def get_countries(session_id)
    response = @api_client.get(countries_endpoint(session_id))
    CountryResponse.validated_response(response)
  end

  def select_a_country(session_id, country)
    @api_client.post(select_a_country_endpoint(session_id, country), '')
  end

  def restart_journey(session_id)
    @api_client.post(restart_journey_endpoint(session_id), '')
  end
end
