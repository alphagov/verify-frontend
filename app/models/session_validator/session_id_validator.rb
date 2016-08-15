require 'session_validator/successful_validation'
require 'session_validator/validation_failure'

class SessionValidator
  class SessionIdValidator
    def validate(cookies, session)
      session_id = cookies[::CookieNames::SESSION_ID_COOKIE_NAME]
      unless session['verify_session_id'] then return ValidationFailure.session_id_missing end
      if session_id == ::CookieNames::NO_CURRENT_SESSION_VALUE
        ValidationFailure.deleted_session
      else
        SuccessfulValidation
      end
    end
  end
end
