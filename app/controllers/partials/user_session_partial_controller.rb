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

  def current_selected_provider_data
    selected_provider_data = SelectedProviderData.from_session(session[:selected_provider])
    raise(Errors::WarningLevelError, 'No selected identity provider data in session') if selected_provider_data.nil?

    selected_provider_data
  end

  def user_journey_type
    journey_type = current_selected_provider_data.journey_type

    raise(Errors::WarningLevelError, 'Unknown selected user journey type in session') unless
        JourneyType::VALID_JOURNEY_TYPES.include?(journey_type)

    journey_type
  end

  def selected_identity_provider
    raise(Errors::WarningLevelError, 'No selected IDP in session') if user_journey_type != JourneyType::VERIFY
    IdentityProvider.from_session(current_selected_provider_data.identity_provider)
  end

  def selected_country
    raise(Errors::WarningLevelError, 'No selected Country in session') if user_journey_type != JourneyType::EIDAS
    Country.from_session(current_selected_provider_data.identity_provider)
  end

  def store_selected_idp_for_session(selected_idp)
    session[:selected_provider] = SelectedProviderData.new(JourneyType::VERIFY, selected_idp)
  end

  def store_selected_country_for_session(selected_country)
    session[:selected_provider] = SelectedProviderData.new(JourneyType::EIDAS, selected_country)
  end
end
