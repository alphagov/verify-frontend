class CookieValidator
  class MissingCookiesValidator
    def validate(cookies, _session)
      missing_cookies = []
      if start_time_cookie_missing?(cookies)
        missing_cookies << ::CookieNames::SESSION_STARTED_TIME_COOKIE_NAME
      end
      if session_id_cookie_missing?(cookies)
        missing_cookies << ::CookieNames::SESSION_ID_COOKIE_NAME
      end
      if secure_cookie_missing?(cookies)
        missing_cookies << ::CookieNames::SECURE_COOKIE_NAME
      end
      if missing_cookies.any?
        ValidationFailure.cookies_missing(missing_cookies)
      else
        SuccessfulValidation
      end
    end

  private

    def start_time_cookie_missing?(cookies)
      !cookies.key? ::CookieNames::SESSION_STARTED_TIME_COOKIE_NAME
    end

    def secure_cookie_missing?(cookies)
      !cookies.key? ::CookieNames::SECURE_COOKIE_NAME
    end

    def session_id_cookie_missing?(cookies)
      !cookies.key? ::CookieNames::SESSION_ID_COOKIE_NAME
    end
  end
end
