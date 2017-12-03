class ConfigProxy
  include ConfigEndpoints

  def initialize(api_client)
    @api_client = api_client
  end

  def get_transaction_details(transaction_entity_id)
    response = @api_client.get(transaction_display_data_endpoint(transaction_entity_id))
    TransactionResponse.validated_response(response)
  end

  def transactions
    @api_client.get(transactions_endpoint)
  end

  def get_idp_list(transaction_id, loa)
    response = @api_client.get(idp_list_endpoint(transaction_id, loa))
    IdpListResponse.validated_response(response)
  end
end
