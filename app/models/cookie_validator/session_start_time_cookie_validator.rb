class CookieValidator
  class SessionStartTimeCookieValidator
    def initialize(session_duration)
      @session_duration = session_duration
    end

    def validate(cookies)
      start_time_cookie_value = cookies[::CookieNames::SESSION_STARTED_TIME_COOKIE_NAME]
      begin
        parsed_time = Time.at(Integer(start_time_cookie_value)).to_datetime
        if parsed_time <= 2.hours.ago
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
