require "partials/journey_hinting_partial_controller"

module IdpSelectionPartialController
  include JourneyHintingPartialController

  def set_journey_hint_followed(entity_id)
    session[:user_followed_journey_hint] = user_followed_journey_hint(entity_id) if has_journey_hint?
  end

  def has_journey_hint?
    !success_entity_id.nil?
  end

  def ajax_idp_redirection_sign_in_request(entity_id)
    shown = has_journey_hint?
    set_journey_hint_followed(entity_id)
    increase_attempt_number
    report_user_idp_attempt_to_piwik
    if shown
      FEDERATION_REPORTER.report_sign_in_idp_selection_after_journey_hint(current_transaction, request, session[:selected_idp_name], session[:user_followed_journey_hint])
    else
      FEDERATION_REPORTER.report_sign_in_idp_selection(current_transaction, request, session[:selected_idp_name])
    end

    outbound_saml_message = SAML_PROXY_API.authn_request(session[:verify_session_id])
    idp_request = idp_request_initialisation(outbound_saml_message)
    render json: idp_request
  end

  def ajax_idp_redirection_sign_in_without_hint_request
    increase_attempt_number
    report_user_idp_attempt_to_piwik
    FEDERATION_REPORTER.report_sign_in_idp_selection(current_transaction, request, session[:selected_idp_name])

    outbound_saml_message = SAML_PROXY_API.authn_request(session[:verify_session_id])
    idp_request = idp_request_initialisation(outbound_saml_message)
    render json: idp_request
  end

  def ajax_idp_redirection_registration_request(recommended, entity_id)
    set_journey_hint_followed(entity_id)
    increase_attempt_number
    report_user_idp_attempt_to_piwik
    report_idp_registration_to_piwik(recommended)
    outbound_saml_message = SAML_PROXY_API.authn_request(session[:verify_session_id])
    idp_request = idp_request_initialisation(outbound_saml_message)
    render json: idp_request
  end

  def ajax_idp_redirection_single_idp_journey_request(uuid)
    increase_attempt_number
    report_user_idp_attempt_to_piwik
    FEDERATION_REPORTER.report_single_idp_journey_selection(current_transaction, request, session[:selected_idp_name])

    outbound_saml_message = SAML_PROXY_API.authn_request(session[:verify_session_id])
    idp_request = idp_request_initialisation_for_single_idp_journey(outbound_saml_message, uuid)
    render json: idp_request
  end

  def ajax_idp_redirection_resume_journey_request
    increase_attempt_number
    report_user_idp_attempt_to_piwik
    FEDERATION_REPORTER.report_idp_resume_journey_selection(current_transaction, request, session[:selected_idp_name])

    outbound_saml_message = SAML_PROXY_API.authn_request(session[:verify_session_id])
    idp_request = idp_request_initialisation(outbound_saml_message)
    render json: idp_request
  end

  def report_user_idp_attempt_to_piwik
    FEDERATION_REPORTER.report_user_idp_attempt(
      current_transaction: current_transaction,
      request: request,
      idp_name: session[:selected_idp_name],
      attempt_number: session[:attempt_number],
      journey_type: session[:journey_type],
      hint_followed: session[:user_followed_journey_hint],
    )
  end

  def report_idp_registration_to_piwik
    FEDERATION_REPORTER.report_idp_registration(
      current_transaction: current_transaction,
      request: request,
      idp_name: session[:selected_idp_name],
      idp_name_history: session[:selected_idp_names],
    )
  end

  def idp_request_initialisation(outbound_saml_message)
    IdentityProviderRequest.new(outbound_saml_message)
  end

  def idp_request_initialisation_for_single_idp_journey(outbound_saml_message, uuid)
    IdentityProviderRequest.new(outbound_saml_message, uuid)
  end

  def increase_attempt_number
    session[:attempt_number] = 0 if session[:attempt_number].nil?
    session[:attempt_number] = session[:attempt_number] + 1
  end
end
