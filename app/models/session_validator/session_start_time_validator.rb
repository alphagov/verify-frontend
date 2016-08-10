class SessionValidator
  class SessionStartTimeValidator
    def initialize(session_duration)
      @session_duration = session_duration
    end

    def validate(cookies, session)
      begin
        session_start_time = session.fetch(:start_time)
        validate_expiry(cookies, session_start_time)
      rescue ArgumentError
        session_start_time = Time.at(Integer(session_start_time) / 1000).to_datetime
        validate_expiry(cookies, session_start_time)
      rescue KeyError
        ValidationFailure.something_went_wrong('start_time not in session')
      end
    end

  private

    def validate_expiry(cookies, session_start_time)
      if session_start_time <= @session_duration.hours.ago
        session_id = cookies[::CookieNames::SESSION_ID_COOKIE_NAME]
        ValidationFailure.session_expired(session_id)
      else
        SuccessfulValidation
      end
    end
  end
end
