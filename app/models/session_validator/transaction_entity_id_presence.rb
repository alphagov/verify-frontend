class SessionValidator
  class TransactionEntityIdPresence
    ERROR_MESSAGE = "Transaction entity ID can not be found in the user's session".freeze
    def validate(_cookies, session)
      if session[:transaction_entity_id].nil?
        ValidationFailure.something_went_wrong(ERROR_MESSAGE)
      else
        SuccessfulValidation
      end
    end
  end
end
