module PolicyEndpoints
  PATH = '/policy'.freeze
  PATH_PREFIX = Pathname(PATH)
  SELECT_IDP_SUFFIX = 'select-identity-provider'.freeze
  PARAM_ORIGINATING_IP = 'originatingIp'.freeze
  PARAM_ENTITY_ID = 'entityId'.freeze
  PARAM_REGISTRATION = 'registration'.freeze

  def policy_endpoint(session_id, suffix)
    PATH_PREFIX.join(session_id, suffix).to_s
  end

  def select_idp_endpoint(session_id)
    policy_endpoint(session_id, SELECT_IDP_SUFFIX)
  end
end
