module ConfigEndpoints
  PATH = '/config'.freeze
  PATH_PREFIX = Pathname(PATH)
  IDP_LIST_SUFFIX = 'idps/idp-list/%s/%s'.freeze
  IDP_LIST_SIGN_IN_SUFFIX = 'idps/idp-list-for-sign-in/%s'.freeze
  DISPLAY_DATA_SUFFIX = 'transactions/%s/display-data'.freeze
  TRANSACTIONS_SUFFIX = 'transactions/enabled'.freeze

  def idp_list_endpoint(transaction_id, loa)
    PATH_PREFIX.join(IDP_LIST_SUFFIX % [CGI.escape(transaction_id), CGI.escape(loa)]).to_s
  end

  def idp_list_for_sign_in_endpoint(transaction_id)
    PATH_PREFIX.join(IDP_LIST_SIGN_IN_SUFFIX % [CGI.escape(transaction_id)]).to_s
  end

  def transactions_endpoint
    PATH_PREFIX.join(TRANSACTIONS_SUFFIX).to_s
  end

  def transaction_display_data_endpoint(transaction_entity_id)
    PATH_PREFIX.join(DISPLAY_DATA_SUFFIX % CGI.escape(transaction_entity_id)).to_s
  end
end
