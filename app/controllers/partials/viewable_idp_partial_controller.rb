module ViewableIdpPartialController
  def select_viewable_idp_for_sign_in(entity_id)
    for_viewable_idp(entity_id, identity_providers_available_for_sign_in) do |decorated_idp|
      store_selected_idp_for_session(decorated_idp.identity_provider)
      yield decorated_idp
    end
  end

  def select_viewable_idp_for_registration(entity_id)
    for_viewable_idp(entity_id, identity_providers_available_for_registration) do |decorated_idp|
      store_selected_idp_for_session(decorated_idp.identity_provider)
      yield decorated_idp
    end
  end

  def select_viewable_idp_for_single_idp_journey(entity_id)
    for_viewable_idp(entity_id, identity_providers_for_single_idp) do |decorated_idp|
      store_selected_idp_for_session(decorated_idp.identity_provider)
      yield decorated_idp
    end
  end

  def for_viewable_idp(entity_id, identity_provider_list)
    matching_idp = identity_provider_list.detect { |idp| idp.entity_id == entity_id }
    idp = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate(matching_idp)
    if idp.viewable?
      yield idp
    else
      simple_id = matching_idp.nil? ? nil : matching_idp.simple_id
      logger.error "Viewable IdP not found for entity ID #{entity_id} with simple ID #{simple_id}"
      render_not_found
    end
  end

  def identity_providers_for_sign_in
    sign_in_idps = identity_providers_for_sign_in_full_list

    unavailable_idps = sign_in_idps.select(&:unavailable)
    sign_in_idps -= unavailable_idps

    disconnected_idps = sign_in_idps.select { |idp| !idp.authentication_enabled || idp_disconnected_for_sign_in?(idp) }
    sign_in_idps -= disconnected_idps

    available_idps = sign_in_idps

    {
      available: available_idps,
      unavailable: unavailable_idps,
      disconnected: disconnected_idps,
    }
  end

  def identity_providers_available_for_sign_in
    identity_providers_for_sign_in[:available]
  end

  def identity_providers_unavailable_for_sign_in
    identity_providers_for_sign_in[:unavailable]
  end

  def identity_providers_disconnected_for_sign_in
    identity_providers_for_sign_in[:disconnected]
  end

  def identity_providers_available_for_registration
    identity_providers_for_registration.reject { |idp| idp_already_tried?(idp) || is_idp_hidden_for_registration?(idp) }
  end

  def identity_providers_for_single_idp
    CONFIG_PROXY.get_idp_list_for_single_idp(session[:transaction_entity_id]).idps
  end

  def order_with_unavailable_last(idps)
    idps.reject(&:unavailable) + idps.select(&:unavailable)
  end

  def idps_tried
    session[:idps_tried] = Set.new(session[:idps_tried]) unless session[:idps_tried].is_a? Set
    session[:idps_tried]
  end

  def mark_idp_as_tried(idp_simple_id)
    idps_tried.add(idp_simple_id)
  end

private

  def identity_providers_for_sign_in_full_list
    CONFIG_PROXY.get_idp_list_for_sign_in(session[:transaction_entity_id]).idps
  end

  def identity_providers_for_registration
    CONFIG_PROXY.get_available_idp_list_for_registration(session[:transaction_entity_id], session[:requested_loa]).idps
  end

  def is_idp_hidden_for_registration?(idp)
    return false if idp.provide_registration_until.nil?

    idp.provide_registration_until - CONFIG.hide_idps_disconnecting_for_registration_minutes_before < DateTime.now
  end

  def idp_disconnected_for_sign_in?(idp)
    idp.provide_authentication_until.present? && idp.provide_authentication_until < 2.hours.from_now
  end

  def idp_already_tried?(idp)
    idps_tried.include? idp.simple_id
  end
end
