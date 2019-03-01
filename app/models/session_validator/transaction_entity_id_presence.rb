class SessionValidator
  class TransactionEntityIdPresence
    ERROR_MESSAGE = "Transaction entity ID can not be found in the user's session".freeze
    def validate(_cookies, session)
      if session.include?(:transaction_entity_id)
        SuccessfulValidation
      else
        ValidationFailure.something_went_wrong(ERROR_MESSAGE)
      end
    end
  end
end
