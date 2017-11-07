module PolicyEndpoints
  PATH = '/policy/received-authn-request'.freeze
  PATH_PREFIX = Pathname(PATH)
  SELECT_IDP_SUFFIX = 'select-identity-provider'.freeze
  MATCHING_OUTCOME_SUFFIX = 'response-from-idp/response-processing-details'.freeze
  PARAM_PRINCIPAL_IP = 'principalIpAddress'.freeze
  PARAM_CYCLE_3_INPUT = 'cycle3Input'.freeze
  PARAM_SELECTED_ENTITY_ID = 'selectedIdpEntityId'.freeze
  PARAM_REGISTRATION = 'registration'.freeze
  CYCLE_THREE_SUFFIX = 'cycle-3-attribute'.freeze
  CYCLE_THREE_SUBMIT_SUFFIX = "#{CYCLE_THREE_SUFFIX}/submit".freeze
  CYCLE_THREE_CANCEL_SUFFIX = "#{CYCLE_THREE_SUFFIX}/cancel".freeze

  def policy_endpoint(session_id, suffix)
    PATH_PREFIX.join(session_id, suffix).to_s
  end

  def select_idp_endpoint(session_id)
    policy_endpoint(session_id, SELECT_IDP_SUFFIX)
  end

  def matching_outcome_endpoint(session_id)
    policy_endpoint(session_id, MATCHING_OUTCOME_SUFFIX)
  end

  def cycle_three_endpoint(session_id)
    policy_endpoint(session_id, CYCLE_THREE_SUFFIX)
  end

  def cycle_three_submit_endpoint(session_id)
    policy_endpoint(session_id, CYCLE_THREE_SUBMIT_SUFFIX)
  end

  def cycle_three_cancel_endpoint(session_id)
    policy_endpoint(session_id, CYCLE_THREE_CANCEL_SUFFIX)
  end
end
