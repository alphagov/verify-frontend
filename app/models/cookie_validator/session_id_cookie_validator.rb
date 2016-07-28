class CookieValidator
  class SessionIdCookieValidator
    def validate(cookies, _session)
      session_id = cookies[::CookieNames::SESSION_ID_COOKIE_NAME]
      if session_id == ::CookieNames::NO_CURRENT_SESSION_VALUE
        ValidationFailure.deleted_session
      else
        SuccessfulValidation
      end
    end
  end
end
