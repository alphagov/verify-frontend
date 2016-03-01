module Api
  class SessionTimeoutError < StandardError
    TYPE = 'SESSION_TIMEOUT'
  end
end
