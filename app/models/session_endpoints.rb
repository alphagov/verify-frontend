module SessionEndpoints
  PATH = '/api/session'.freeze
  PATH_PREFIX = Pathname(PATH)
  IDP_LIST_SUFFIX = 'idp-list'.freeze
  SELECT_IDP_SUFFIX = 'select-idp'.freeze
  IDP_AUTHN_REQUEST_SUFFIX = 'idp-authn-request'.freeze
  IDP_AUTHN_RESPONSE_SUFFIX = 'idp-authn-response'.freeze
  SESSION_STATE_PATH = "#{PATH}/state".freeze
  MATCHING_OUTCOME_SUFFIX = 'matching-outcome'.freeze
  RESPONSE_FOR_RP_SUFFIX = 'response-for-rp/success'.freeze
  ERROR_RESPONSE_FOR_RP_SUFFIX = 'response-for-rp/error'.freeze
  CYCLE_THREE_SUFFIX = 'cycle-three'.freeze
  CYCLE_THREE_CANCEL_SUFFIX = "#{CYCLE_THREE_SUFFIX}/cancel".freeze
  PARAM_SAML_REQUEST = 'samlRequest'.freeze
  PARAM_SAML_RESPONSE = 'samlResponse'.freeze
  PARAM_RELAY_STATE = 'relayState'.freeze
  PARAM_ORIGINATING_IP = 'originatingIp'.freeze
  PARAM_ENTITY_ID = 'entityId'.freeze
  PARAM_REGISTRATION = 'registration'.freeze
  PARAM_CYCLE_THREE_VALUE = 'value'.freeze
  COUNTRIES_PATH = '/api/countries'.freeze
  SESSION_ID = 'sessionId'.freeze
  COUNTRIES_PATH_PREFIX = Pathname(COUNTRIES_PATH)
  COUNTRY_AUTHN_REQUEST_SUFFIX = 'country-authn-request'.freeze
  COUNTRY_AUTHN_RESPONSE_SUFFIX = 'country-authn-response'.freeze

  def countries_endpoint(session_id)
    COUNTRIES_PATH_PREFIX.join(session_id).to_s
  end

  def select_a_country_endpoint(session_id, suffix)
    COUNTRIES_PATH_PREFIX.join(session_id, suffix).to_s
  end

  def session_endpoint(session_id, suffix)
    PATH_PREFIX.join(session_id, suffix).to_s
  end

  def select_idp_endpoint(session_id)
    session_endpoint(session_id, SELECT_IDP_SUFFIX)
  end

  def country_authn_request_endpoint(session_id)
    session_endpoint(session_id, COUNTRY_AUTHN_REQUEST_SUFFIX)
  end

  def idp_authn_request_endpoint(session_id)
    session_endpoint(session_id, IDP_AUTHN_REQUEST_SUFFIX)
  end

  def idp_authn_response_endpoint(session_id)
    session_endpoint(session_id, IDP_AUTHN_RESPONSE_SUFFIX)
  end

  def matching_outcome_endpoint(session_id)
    session_endpoint(session_id, MATCHING_OUTCOME_SUFFIX)
  end

  def response_for_rp_endpoint(session_id)
    session_endpoint(session_id, RESPONSE_FOR_RP_SUFFIX)
  end

  def error_response_for_rp_endpoint(session_id)
    session_endpoint(session_id, ERROR_RESPONSE_FOR_RP_SUFFIX)
  end

  def cycle_three_endpoint(session_id)
    session_endpoint(session_id, CYCLE_THREE_SUFFIX)
  end

  def cycle_three_cancel_endpoint(session_id)
    session_endpoint(session_id, CYCLE_THREE_CANCEL_SUFFIX)
  end
end
