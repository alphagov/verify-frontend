class SessionValidator
  class IdpPresence
    ERROR_MESSAGE = "Idp(s) can not be found in the user's session".freeze
    def validate(_cookies, session)
      if session.include?(:identity_providers)
        SuccessfulValidation
      else
        ValidationFailure.something_went_wrong(ERROR_MESSAGE)
      end
    end
  end
end
