class CookieValidator
  class SessionStartTimeCookieValidator
    def initialize(session_duration)
      @session_duration = session_duration
    end

    def validate(cookies)
      start_time_cookie_value = cookies[::CookieNames::SESSION_STARTED_TIME_COOKIE_NAME]
      begin
        session_start_time_s = Integer(start_time_cookie_value) / 1000
        parsed_time = Time.at(session_start_time_s).to_datetime
        if parsed_time <= @session_duration.hours.ago
          session_id = cookies[::CookieNames::SESSION_ID_COOKIE_NAME]
          ValidationFailure.session_cookie_expired(session_id)
        else
          SuccessfulValidation
        end
      rescue TypeError, ArgumentError
        ValidationFailure.something_went_wrong("The session start time cookie, '#{start_time_cookie_value}', can't be parsed")
      end
    end
  end
end
