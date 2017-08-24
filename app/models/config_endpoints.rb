module ConfigEndpoints
  PATH = '/config'.freeze
  PATH_PREFIX = Pathname(PATH)
  IDP_LIST_SUFFIX = 'idps/idp-list'.freeze

  def idp_list_endpoint(transaction_id)
    transaction_id_query_parameter = { transactionEntityId: transaction_id }.to_query
    PATH_PREFIX.join(IDP_LIST_SUFFIX).to_s + "?#{transaction_id_query_parameter}"
  end
end
