class CookieValidator
  class NoCookiesValidator
    def validate(cookies)
      if all_cookies_missing?(cookies)
        NoCookiesValidation.new
      else
        SuccessfulValidation
      end
    end

  private

    def all_cookies_missing?(cookies)
      cookies.select { |name, _| CookieNames.session_cookies.include?(name) }.empty?
    end
  end

  class MissingCookiesValidator
    def validate(cookies)
      missing_cookies = []
      if start_time_cookie_missing?(cookies)
        missing_cookies << CookieNames::SESSION_STARTED_TIME_COOKIE_NAME
      end
      if session_id_cookie_missing?(cookies)
        missing_cookies << CookieNames::SESSION_ID_COOKIE_NAME
      end
      if secure_cookie_missing?(cookies)
        missing_cookies << CookieNames::SECURE_COOKIE_NAME
      end
      if missing_cookies.any?
        CookiesMissingValidation.new(missing_cookies)
      else
        SuccessfulValidation
      end
    end

  private

    def start_time_cookie_missing?(cookies)
      !cookies.key? CookieNames::SESSION_STARTED_TIME_COOKIE_NAME
    end

    def secure_cookie_missing?(cookies)
      !cookies.key? CookieNames::SECURE_COOKIE_NAME
    end

    def session_id_cookie_missing?(cookies)
      !cookies.key? CookieNames::SESSION_ID_COOKIE_NAME
    end
  end

  class SessionStartTimeCookieValidator
    def validate(cookies)
      start_time_cookie_value = cookies[CookieNames::SESSION_STARTED_TIME_COOKIE_NAME]
      begin
        parsed_time = Time.at(Integer(start_time_cookie_value)).to_datetime
        if parsed_time <= 2.hours.ago
          session_id = cookies[CookieNames::SESSION_ID_COOKIE_NAME]
          ExpiredStartTimeCookieValidation.new(session_id)
        else
          SuccessfulValidation
        end
      rescue TypeError, ArgumentError
        SessionStartTimeParseValidation.new(start_time_cookie_value)
      end
    end
  end

  def initialize
    @validators = [
      NoCookiesValidator.new,
      MissingCookiesValidator.new,
      SessionStartTimeCookieValidator.new
    ]
  end

  def validate(cookies)
    @validators.lazy.map { |validator| validator.validate(cookies) }.detect { |result| !result.ok? } || SuccessfulValidation
  end

  class SessionStartTimeParseValidation
    def initialize(cookie_value)
      @cookie_value = cookie_value
    end

    def ok?
      false
    end

    def no_cookies?
      false
    end

    def message
      "The session start time cookie, '#{@cookie_value}', can't be parsed"
    end
  end

  class ExpiredStartTimeCookieValidation
    def initialize(session_id)
      @session_id = session_id
    end

    def ok?
      false
    end

    def no_cookies?
      false
    end

    def cookie_expired?
      true
    end

    def message
      "session_start_time cookie for session \"#{@session_id}\" has expired"
    end
  end

  class CookiesMissingValidation
    def initialize(missing_cookies)
      @cookies = missing_cookies
    end

    def no_cookies?
      false
    end

    def ok?
      false
    end

    def cookie_expired?
      false
    end

    def message
      "The following cookies are missing: [#{@cookies.join(', ')}]"
    end
  end

  class Validation
    def no_cookies?
      false
    end

    def ok?
      true
    end

    def cookie_expired?
      false
    end
  end

  class NoCookiesValidation
    def no_cookies?
      true
    end

    def ok?
      false
    end

    def cookie_expired?
      false
    end

    def message
      "No session cookies can be found"
    end
  end
  SuccessfulValidation = Validation.new
end
