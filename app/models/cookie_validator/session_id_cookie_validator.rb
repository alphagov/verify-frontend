class CookieValidator
  class SessionIdCookieValidator
    NO_CURRENT_SESSION = 'no-current-session'.freeze
    def validate(cookies, _session)
      session_id = cookies[::CookieNames::SESSION_ID_COOKIE_NAME]
      if session_id == NO_CURRENT_SESSION
        ValidationFailure.deleted_session
      else
        SuccessfulValidation
      end
    end
  end
end
