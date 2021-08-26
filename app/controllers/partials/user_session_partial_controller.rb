module UserSessionPartialController
  def validate_session
    validation = session_validator.validate(cookies, session)
    unless validation.ok?
      logger.info(validation.message)
      render_error(validation.type, validation.status)
    end
  end

  def session_validator
    SESSION_VALIDATOR
  end

  def current_transaction_simple_id
    session[:transaction_simple_id]
  end

  def current_transaction_entity_id
    session[:transaction_entity_id]
  end

  def current_transaction_homepage
    session[:transaction_homepage]
  end

  def requested_loa
    session[:requested_loa]
  end

  def is_journey_loa1?
    session[:requested_loa] == "LEVEL_1"
  end

  def is_journey_loa2?
    session[:requested_loa] == "LEVEL_2"
  end

  def current_selected_provider_data
    selected_provider_data = SelectedProviderData.from_session(session[:selected_provider])
    raise(Errors::WarningLevelError, "No selected identity provider data in session") if selected_provider_data.nil?

    selected_provider_data
  end

  def selected_identity_provider
    IdentityProvider.from_session(current_selected_provider_data.identity_provider)
  end

  def identity_provider_selected?
    !SelectedProviderData.from_session(session[:selected_provider]).nil?
  end

  def selected_provider
    IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate(selected_identity_provider)
  end

  def store_selected_idp_for_session(selected_idp)
    session[:selected_provider] = SelectedProviderData.new(selected_idp)
  end
end
