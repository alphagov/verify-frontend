class SessionValidator
  class SessionStartTimeValidator
    def initialize(session_duration)
      @session_duration = session_duration
    end

    def validate(cookies, session)
      begin
        session_start_time_s = Integer(session.fetch(:start_time)) / 1000
        parsed_time = Time.at(session_start_time_s).to_datetime
        if parsed_time <= @session_duration.hours.ago
          session_id = cookies[::CookieNames::SESSION_ID_COOKIE_NAME]
          ValidationFailure.session_expired(session_id)
        else
          SuccessfulValidation
        end
      rescue KeyError
        ValidationFailure.something_went_wrong('start_time not in session')
      rescue TypeError, ArgumentError
        ValidationFailure.something_went_wrong("The session start time, \"#{session[:start_time]}\", cannot be parsed")
      end
    end
  end
end
