class SessionValidator
  class SessionStartTimeValidator
    def initialize(session_duration)
      @session_duration = session_duration
    end

    def validate(cookies, session)
      begin
        session_start_time = session.fetch(:start_time)
        if session_start_time <= @session_duration.hours.ago
          session_id = cookies[::CookieNames::SESSION_ID_COOKIE_NAME]
          ValidationFailure.session_expired(session_id)
        else
          SuccessfulValidation
        end
      rescue KeyError
        ValidationFailure.something_went_wrong('start_time not in session')
      end
    end
  end
end
