class ConfigProxy
  include ConfigEndpoints

  def initialize(api_client)
    @api_client = api_client
  end

  def get_transaction_details(transaction_entity_id)
    response = @api_client.get(transaction_display_data_endpoint(transaction_entity_id))
    TransactionResponse.validated_response(response)
  end

  def get_transaction_translations(transaction_entity_id)
    response = @api_client.get(transaction_translation_data_endpoint(transaction_entity_id))

    translations = {}

    response.keys.each do |locale|
      translations_for_locale = TransactionTranslationResponse.validated_response(response[locale])

      translations[locale] = {
        name: translations_for_locale.name,
        rp_name: translations_for_locale.rp_name,
        analytics_description: translations_for_locale.analytics_description,
        other_ways_text: translations_for_locale.other_ways_text,
        other_ways_description: translations_for_locale.other_ways_description,
        tailored_text: translations_for_locale.tailored_text,
        taxon_name: translations_for_locale.taxon_name
      }
    end

    translations
    #
  end

  def transactions
    @api_client.get(transactions_endpoint)
  end

  def get_idp_list_for_loa(transaction_id, loa)
    response = @api_client.get(idp_list_for_loa_endpoint(transaction_id, loa))
    IdpListResponse.validated_response(response)
  end

  def get_idp_list_for_sign_in(transaction_id)
    response = @api_client.get(idp_list_for_sign_in_endpoint(transaction_id))
    IdpListResponse.validated_response(response)
  end
end
