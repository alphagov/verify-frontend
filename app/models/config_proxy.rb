class ConfigProxy
  include ConfigEndpoints

  def initialize(api_client)
    @api_client = api_client
  end

  def get_transaction_details(transaction_entity_id)
    response = @api_client.get(transaction_display_data_endpoint(transaction_entity_id))
    TransactionResponse.validated_response(response)
  end

  def get_transaction_translations(transaction_simple_id, locale)
    begin
      response = @api_client.get(transaction_translation_data_endpoint(transaction_simple_id, locale))
      translations_for_locale = TransactionTranslationResponse.validated_response(response)

      translations_for_locale.to_h
    rescue Api::Error, TypeError
      {}
    end
  end

  def transactions
    @api_client.get(transactions_endpoint)
  end

  def get_transaction_by_simple_id(transaction_simple_id)
    transactions_list = transactions

    transactions_list.find { |transaction| transaction.fetch("simpleId") == transaction_simple_id } unless transactions_list.nil?
  end

  def transactions_for_single_idp_list
    @api_client.get(transactions_for_single_idp_list_endpoint)
  end

  def get_available_idp_list_for_registration(transaction_id, loa)
    response = @api_client.get(idp_list_for_registration_endpoint(transaction_id, loa))
    IdpListResponse.validated_response(response)
  end

  def get_idp_list_for_sign_in(transaction_id)
    response = @api_client.get(idp_list_for_sign_in_endpoint(transaction_id))
    IdpListResponse.validated_response(response)
  end

  def get_idp_list_for_single_idp(transaction_id)
    response = @api_client.get(idp_list_for_single_idp_endpoint(transaction_id))
    IdpListResponse.validated_response(response)
  end
end
