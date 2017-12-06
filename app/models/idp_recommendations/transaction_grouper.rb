module TransactionGroups
  PROTECTED = 'protected'.freeze
  NON_PROTECTED = 'non_protected'.freeze

  class TransactionGrouper
    def initialize(transaction_config)
      @protected_transactions = transaction_config.fetch('protected_transactions', [])
    end

    def get_transaction_group(transaction_simple_id)
      @protected_transactions.include?(transaction_simple_id) ? TransactionGroups::PROTECTED : TransactionGroups::NON_PROTECTED
    end
  end
end
