module RetrieveFederationDataPartialController
  def get_selected_rp_from_entity_id(list, entity_id)
    return nil if list.nil?
    list.select { |hash| hash.fetch('entityId') == entity_id }.first
  end

  def get_single_idp_url(list, transaction_id)
    selected_rp = get_selected_rp_from_entity_id(list, transaction_id)
    get_rp_attribute(selected_rp, 'redirectUrl')
  end

  def get_rp_attribute(selected_rp, attribute)
    return nil if selected_rp.nil?
    selected_rp.fetch(attribute, nil)
  end

  def get_idp_choice(list, idp_entity_id)
    return false if list.nil?
    list.select { |idp| idp.entity_id == idp_entity_id }.first
  end

  def valid_transaction?(list, transaction_id)
    list.detect { |hash| hash.fetch('entityId') == transaction_id }
  end

  def valid_idp_choice?(list, idp_entity_id)
    return false if list.nil?
    list.detect { |idp| idp.entity_id == idp_entity_id }
  end

  def get_transaction_entity_id(selected_rp)
    return nil if selected_rp.nil?
    selected_rp.fetch('entityId', nil)
  end
end
