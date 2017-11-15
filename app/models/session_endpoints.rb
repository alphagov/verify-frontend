module SessionEndpoints
  PATH = '/api/session'.freeze
  PATH_PREFIX = Pathname(PATH)
  IDP_LIST_SUFFIX = 'idp-list'.freeze
  SELECT_IDP_SUFFIX = 'select-idp'.freeze
  SESSION_STATE_PATH = "#{PATH}/state".freeze
  PARAM_SAML_REQUEST = 'samlRequest'.freeze
  PARAM_SAML_RESPONSE = 'samlResponse'.freeze
  PARAM_RELAY_STATE = 'relayState'.freeze
  PARAM_ORIGINATING_IP = 'originatingIp'.freeze
  PARAM_ENTITY_ID = 'entityId'.freeze

  def session_endpoint(session_id, suffix)
    PATH_PREFIX.join(session_id, suffix).to_s
  end
end
