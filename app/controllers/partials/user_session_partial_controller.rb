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
    if selected_idp.nil?
      raise(Errors::WarningLevelError, 'No selected IDP in session')
    else
      IdentityProvider.from_session(selected_idp)
    end
  end
end
