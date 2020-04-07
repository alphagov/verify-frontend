module Api
  class SessionError < StandardError
    TYPE = "SESSION_ERROR".freeze

    #This was called SESSION_ERROR by frontend api
    HUB_TYPE = "EXPECTED_SESSION_STARTED_STATE_ACTUAL_IDP_SELECTED_STATE".freeze
  end
end
