class CookieValidator
  class NoCookiesValidator
    def validate(cookies)
      if all_cookies_missing?(cookies)
        ValidationFailure.no_cookies
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
        ValidationFailure.cookies_missing(missing_cookies)
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
          ValidationFailure.session_cookie_expired(session_id)
        else
          SuccessfulValidation
        end
      rescue TypeError, ArgumentError
        ValidationFailure.something_went_wrong("The session start time cookie, '#{start_time_cookie_value}', can't be parsed")
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

  class ValidationFailure
    def self.something_went_wrong(message)
      ValidationFailure.new(:something_went_wrong, :internal_server_error, message)
    end

    def self.session_cookie_expired(session_id)
      message = "session_start_time cookie for session \"#{session_id}\" has expired"
      ValidationFailure.new(:cookie_expired, :bad_request, message)
    end

    def self.no_cookies
      message = "No session cookies can be found"
      ValidationFailure.new(:no_cookies, :forbidden, message)
    end

    def self.cookies_missing(cookies)
      message = "The following cookies are missing: [#{cookies.join(', ')}]"
      ValidationFailure.new(:something_went_wrong, :internal_server_error, message)
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

  class Validation
    def ok?
      true
    end
  end

  SuccessfulValidation = Validation.new
end
