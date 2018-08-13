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

  def selected_identity_provider
    selected_idp = session[:selected_idp]
    raise(Errors::WarningLevelError, 'No selected IDP in session') if selected_idp.nil?

    IdentityProvider.from_session(selected_idp)
  end

  def selected_country
    selected_country = session[:selected_country]
    raise(Errors::WarningLevelError, 'No selected Country in session') if selected_country.nil?

    Country.from_session(selected_country)
  end
end
