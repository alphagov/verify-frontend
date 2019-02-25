class SessionValidator
  class TransactionEntityIdPresence
    ERROR_MESSAGE = "Transaction entity ID can not be found in the user's session".freeze
    def validate(_cookies, session)
      # When confident of no false positives, remove the log and reinstate the validation failure.
      # if session.include?(:transaction_entity_id)
      #   SuccessfulValidation
      # else
      #   ValidationFailure.something_went_wrong(ERROR_MESSAGE)
      # end

      Rails.logger.error(ERROR_MESSAGE) unless session.include?(:transaction_entity_id)
      SuccessfulValidation
    end
  end
end
