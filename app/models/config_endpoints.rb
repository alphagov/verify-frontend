module ConfigEndpoints
  PATH = '/config'.freeze
  PATH_PREFIX = Pathname(PATH)
  IDP_LIST_SUFFIX = 'idps/idp-list'.freeze

  def idp_list_endpoint(transaction_id)
    PATH_PREFIX.join(IDP_LIST_SUFFIX).to_s + "?transactionEntityId=#{transaction_id}"
  end
end
