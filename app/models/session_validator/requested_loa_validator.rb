class SessionValidator
  class RequestedLOAValidator
    ERROR_MESSAGE = "Requested LOA can not be found in the user's session".freeze
    def validate(_cookies, session)
      if session.include?(:requested_loa)
        SuccessfulValidation
      else
        ValidationFailure.something_went_wrong(ERROR_MESSAGE)
      end
    end
  end
end
