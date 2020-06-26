module Api
  class SessionTimeoutError < Api::Error
    TYPE = "SESSION_TIMEOUT".freeze
  end
end
