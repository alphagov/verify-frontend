class SessionValidator
  class MissingCookiesValidator
    def validate(cookies, _session)
      missing_cookies = missing_session_cookies(cookies, [
          ::CookieNames::SESSION_ID_COOKIE_NAME,
          ::CookieNames::SESSION_COOKIE_NAME])
      if missing_cookies.any?
        ValidationFailure.cookies_missing(missing_cookies)
      else
        SuccessfulValidation
      end
    end

  private

    def missing_session_cookies(cookies, cookie_names)
      cookie_names.select { |cookie_name| !cookies.key? cookie_name }
    end
  end
end
