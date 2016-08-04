class SessionValidator
  class TransactionSimpleIdPresence
    ERROR_MESSAGE = "Transaction simple ID can not be found in the user's session".freeze
    def validate(_cookies, session)
      if session.include?(:transaction_simple_id)
        SuccessfulValidation
      else
        ValidationFailure.something_went_wrong(ERROR_MESSAGE)
      end
    end
  end
end
