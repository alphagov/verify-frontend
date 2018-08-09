module TransactionsPartialController
  def transaction_taxon_list
    TRANSACTION_TAXON_CORRELATOR.correlate(CONFIG_PROXY.transactions)
  end

  def transactions_list
    DATA_CORRELATOR.correlate(CONFIG_PROXY.transactions)
  end

  def transactions_for_service_list
    SERVICE_LIST_DATA_CORRELATOR.correlate(CONFIG_PROXY.transactions_for_service_list)
  end

  def current_service
    DATA_CORRELATOR.retrieve_current_service(CONFIG_PROXY.transactions, session[:transaction_simple_id])
  end

  def loa1_transactions_list
    Display::Rp::TransactionFilter.new.filter_by_loa(transactions_list, 'LEVEL_1')
  end

  def loa2_transactions_list
    Display::Rp::TransactionFilter.new.filter_by_loa(transactions_list, 'LEVEL_2')
  end

  def current_transaction
    @current_transaction ||= RP_DISPLAY_REPOSITORY.get_translations(current_transaction_simple_id)
  end
end
