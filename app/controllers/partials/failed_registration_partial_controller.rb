module FailedRegistrationPartialController
  def other_idp_to_try
    idps = IDP_RECOMMENDATION_ENGINE.get_suggested_idps(current_identity_providers_for_loa, selected_evidence, current_transaction_simple_id)[:recommended]
    if idps.length == 2
      idps.delete(selected_identity_provider)
      IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate(idps.first)
    else
      return nil
    end
  end
end
