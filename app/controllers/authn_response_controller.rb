require 'partials/user_cookies_partial_controller'

class AuthnResponseController < SamlController
  protect_from_forgery except: %i[idp_response country_response]

  SIGNING_IN_STATE = 'SIGN_IN_WITH_IDP'.freeze
  REGISTERING_STATE = 'REGISTER_WITH_IDP'.freeze
  SUCCESS = 'SUCCESS'.freeze
  CANCEL = 'CANCEL'.freeze
  FAILED = 'FAILED'.freeze
  FAILED_UPLIFT = 'FAILED_UPLIFT'.freeze
  PENDING = 'PENDING'.freeze
  OTHER = 'OTHER'.freeze

  def idp_response
    raise_error_if_session_mismatch(params['RelayState'], session[:verify_session_id])

    response = SAML_PROXY_API.idp_authn_response(session[:verify_session_id], params['SAMLResponse'])
    idp_response_handlers[response.idp_result].call(response)
  end

  def country_response
    params['RelayState'] ||= session[:verify_session_id] if session[:transaction_supports_eidas]
    raise_error_if_session_mismatch(params['RelayState'], session[:verify_session_id])

    response = SAML_PROXY_API.forward_country_authn_response(params['RelayState'], params['SAMLResponse'])
    country_response_handlers[response.country_result].call(response)
  end

private

  def raise_error_if_session_mismatch(relay_state, session_id)
    error_message = "Relay state should match session id. Relay state was #{relay_state.inspect}"
    raise Errors::WarningLevelError, error_message if relay_state != session_id
  end

  def idp_response_handlers
    handlers = {
      SUCCESS => ->(response) { idp_response_handler_for(SUCCESS, response) },
      CANCEL => ->(response) { idp_response_handler_for(CANCEL, response) },
      FAILED_UPLIFT => ->(response) { idp_response_handler_for(FAILED_UPLIFT, response) },
      PENDING => ->(response) { idp_response_handler_for(PENDING, response) }
    }
    handlers.default = ->(response) { idp_response_handler_for(OTHER, response, FAILED) }
    handlers
  end

  def idp_response_handler_for(status, response, report_status = status)
    analytics_reporters[status].call(response)
    selection_reporters(:selected_idp, report_status).call
    redirecters[status].call(response)
  end

  def country_response_handlers
    handlers = {
      SUCCESS => ->(response) { country_response_handler_for(SUCCESS, response) },
      CANCEL => ->(response) { country_response_handler_for(FAILED, response) },
      FAILED_UPLIFT => ->(response) { country_response_handler_for(FAILED_UPLIFT, response) }
    }
    handlers.default = redirecters[OTHER]
    handlers
  end

  def country_response_handler_for(status, response)
    selection_reporters(:selected_country, status).call
    redirecters[status].call(response)
  end

  def analytics_reporters
    user_state = ->(response) { response.is_registration ? REGISTERING_STATE : SIGNING_IN_STATE }

    {
      SUCCESS => lambda do |response|
        report_to_analytics("Success - #{user_state.call(response)} at LOA #{response.loa_achieved}")
        report_user_outcome_to_piwik(SUCCESS)
      end,
      CANCEL => lambda do |response|
        report_to_analytics("Cancel - #{user_state.call(response)}")
        report_user_outcome_to_piwik(CANCEL)
      end,
      FAILED_UPLIFT => lambda do |response|
        report_to_analytics("Failed Uplift - #{user_state.call(response)}")
        report_user_outcome_to_piwik(FAILED_UPLIFT)
      end,
      PENDING => lambda do |response|
        report_to_analytics("Paused - #{user_state.call(response)}")
        report_user_outcome_to_piwik(PENDING)
      end,
      OTHER => lambda do |response|
        report_to_analytics("Failure - #{user_state.call(response)}")
        report_user_outcome_to_piwik(OTHER)
      end
    }
  end

  def selection_reporters(selected_entity_type, status)
    selected_entity = session[selected_entity_type].try(:fetch, 'entity_id', nil)
    return unless [SUCCESS, CANCEL, FAILED_UPLIFT, PENDING, FAILED].include? status
    ->() { set_journey_hint_by_status(selected_entity, status) }
  end

  def redirecters
    redirect_based_on_journey_type = ->(redirect_paths, response) {
      redirect_to response.is_registration ? redirect_paths[:registration] : redirect_paths[:sign_in]
    }

    {
      SUCCESS => redirect_based_on_journey_type.curry.(registration: confirmation_path, sign_in: response_processing_path),
      CANCEL => redirect_based_on_journey_type.curry.(registration: cancelled_registration_path, sign_in: start_path),
      FAILED => redirect_based_on_journey_type.curry.(registration: failed_registration_path, sign_in: start_path),
      PENDING => redirect_based_on_journey_type.curry.(registration: paused_registration_path, sign_in: paused_registration_path),
      FAILED_UPLIFT => ->(_) { redirect_to failed_uplift_path },
      OTHER => redirect_based_on_journey_type.curry.(registration: failed_registration_path, sign_in: failed_sign_in_path)
    }
  end
end
