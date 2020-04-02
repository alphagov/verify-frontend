class SessionValidator
  class ValidationFailure < Validation
    def self.something_went_wrong(message)
      ValidationFailure.new(:something_went_wrong, :internal_server_error, message)
    end

    def self.session_expired(session_id)
      message = "session \"#{session_id}\" has expired"
      ValidationFailure.new(:session_timeout, :bad_request, message)
    end

    def self.no_cookies
      message = 'No session cookies can be found'
      ValidationFailure.new(:no_cookies, :forbidden, message)
    end

    def self.cookies_missing(cookies)
      message = "The following cookies are missing: [#{cookies.join(', ')}]"
      ValidationFailure.new(:something_went_wrong, :internal_server_error, message)
    end

    DELETED_SESSION_MESSAGE = "Secure cookie was set to a deleted session value 'no-current-session', indicating a previously completed session.".freeze
    def self.deleted_session
      ValidationFailure.new(:something_went_wrong, :forbidden, DELETED_SESSION_MESSAGE)
    end

    def self.session_id_missing
      message = 'Session ID in the rails session is missing'
      ValidationFailure.new(:something_went_wrong, :internal_server_error, message)
    end

    def self.session_id_mismatch
      message = 'Session ID in cookie does not match value in session'
      ValidationFailure.new(:something_went_wrong, :bad_request, message)
    end

    def initialize(type, status, message)
      @type = type
      @status = status
      @message = message
    end

    attr_reader :type, :status, :message

    def ok?
      false
    end
  end
end
