module ConfigEndpoints
  PATH = '/config'.freeze
  PATH_PREFIX = Pathname(PATH)
  IDP_LIST_SUFFIX = 'idps/idp-list'.freeze
  TRANSACTIONS_SUFFIX = 'transactions/enabled'.freeze

  def idp_list_endpoint(transaction_id)
    transaction_id_query_parameter = { transactionEntityId: transaction_id }.to_query
    PATH_PREFIX.join(IDP_LIST_SUFFIX).to_s + "?#{transaction_id_query_parameter}"
  end

  def transactions_endpoint
    PATH_PREFIX.join(TRANSACTIONS_SUFFIX).to_s
  end
end
