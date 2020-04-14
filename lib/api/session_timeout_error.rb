module Api
  class SessionTimeoutError < StandardError
    TYPE = "SESSION_TIMEOUT".freeze
  end
end
