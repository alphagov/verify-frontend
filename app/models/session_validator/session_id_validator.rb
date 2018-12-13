require 'session_validator/successful_validation'
require 'session_validator/validation_failure'

class SessionValidator
  class SessionIdValidator
    def validate(cookies, session)
      session_id = cookies[::CookieNames::SESSION_ID_COOKIE_NAME]
      verify_session_id = session[:verify_session_id]
      unless verify_session_id
        return ValidationFailure.session_id_missing
      end
      if no_session(verify_session_id)
        return ValidationFailure.deleted_session
      end
      if sessions_do_not_match(session_id, verify_session_id)
        return ValidationFailure.session_id_mismatch
      end

      SuccessfulValidation
    end

  private

    def sessions_do_not_match(session_id, verify_session_id)
      verify_session_id != session_id
    end

    def no_session(session_id)
      session_id == ::CookieNames::NO_CURRENT_SESSION_VALUE
    end
  end
end
