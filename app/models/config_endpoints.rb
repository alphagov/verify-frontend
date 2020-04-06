module ConfigEndpoints
  PATH = '/config'.freeze
  PATH_PREFIX = Pathname(PATH)
  IDP_LIST_REGISTRATION_SUFFIX = 'idps/idp-list-for-registration/%<transaction_name>s/%<loa>s'.freeze
  IDP_LIST_SIGN_IN_SUFFIX = 'idps/idp-list-for-sign-in/%<transaction_name>s'.freeze
  IDP_LIST_SINGLE_IDP_SUFFIX = 'idps/idp-list-for-single-idp/%<transaction_name>s'.freeze
  DISPLAY_DATA_SUFFIX = 'transactions/%<transaction_entity_id>s/display-data'.freeze
  TRANSLATION_DATA_SUFFIX = 'transactions/%<transaction_simple_id>s/translations/%<locale>s'.freeze
  TRANSACTIONS_SUFFIX = 'transactions/enabled'.freeze
  TRANSACTIONS_FOR_SINGLE_IDP_LIST_SUFFIX = 'transactions/single-idp-enabled-list'.freeze

  def idp_list_for_registration_endpoint(transaction_id, loa)
    PATH_PREFIX.join(IDP_LIST_REGISTRATION_SUFFIX % { transaction_name: CGI.escape(transaction_id), loa: CGI.escape(loa) }).to_s
  end

  def idp_list_for_sign_in_endpoint(transaction_id)
    PATH_PREFIX.join(IDP_LIST_SIGN_IN_SUFFIX % { transaction_name: CGI.escape(transaction_id) }).to_s
  end

  def idp_list_for_single_idp_endpoint(transaction_id)
    PATH_PREFIX.join(IDP_LIST_SINGLE_IDP_SUFFIX % { transaction_name: CGI.escape(transaction_id) }).to_s
  end

  def transactions_endpoint
    PATH_PREFIX.join(TRANSACTIONS_SUFFIX).to_s
  end

  def transactions_for_single_idp_list_endpoint
    PATH_PREFIX.join(TRANSACTIONS_FOR_SINGLE_IDP_LIST_SUFFIX).to_s
  end

  def transaction_display_data_endpoint(transaction_entity_id)
    PATH_PREFIX.join(DISPLAY_DATA_SUFFIX % { transaction_entity_id: CGI.escape(transaction_entity_id) }).to_s
  end

  def transaction_translation_data_endpoint(transaction_simple_id, locale)
    PATH_PREFIX.join(TRANSLATION_DATA_SUFFIX % { transaction_simple_id: CGI.escape(transaction_simple_id), locale: locale }).to_s
  end
end
