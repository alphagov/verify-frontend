module PolicyEndpoints
  PATH = '/policy/received-authn-request'.freeze
  PATH_PREFIX = Pathname(PATH)
  SELECT_IDP_SUFFIX = 'select-identity-provider'.freeze
  PARAM_PRINCIPAL_IP = 'principalIpAddress'.freeze
  PARAM_SELECTED_ENTITY_ID = 'selectedIdpEntityId'.freeze
  PARAM_REGISTRATION = 'registration'.freeze

  def policy_endpoint(session_id, suffix)
    PATH_PREFIX.join(session_id, suffix).to_s
  end

  def select_idp_endpoint(session_id)
    policy_endpoint(session_id, SELECT_IDP_SUFFIX)
  end
end
