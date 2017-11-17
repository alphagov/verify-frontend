module ConfigEndpoints
  PATH = '/config'.freeze
  PATH_PREFIX = Pathname(PATH)
  IDP_LIST_SUFFIX = 'idps/idp-list/%s/%s'.freeze
  TRANSACTIONS_SUFFIX = 'transactions/enabled'.freeze

  def idp_list_endpoint(transaction_id, loa)
    PATH_PREFIX.join(IDP_LIST_SUFFIX % [CGI.escape(transaction_id), CGI.escape(loa)]).to_s
  end

  def transactions_endpoint
    PATH_PREFIX.join(TRANSACTIONS_SUFFIX).to_s
  end
end
