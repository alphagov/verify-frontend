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
    if params['RelayState'].nil?
      if session[:transaction_supports_eidas]
        params['RelayState'] = session[:verify_session_id]
      end
    end
    raise_error_if_session_mismatch(params['RelayState'], session[:verify_session_id])

    response = SAML_PROXY_API.forward_country_authn_response(params['RelayState'], params['SAMLResponse'])
    country_response_handlers[response.country_result].call(response)
  end

private

  def raise_error_if_session_mismatch(relay_state, session_id)
    if relay_state != session_id
      raise Errors::WarningLevelError, "Relay state should match session id. Relay state was #{relay_state.inspect}"
    end
  end

  def idp_response_handlers
    handlers = {
      SUCCESS => ->(response) { analytics_reporters[SUCCESS].call(response); idp_selection_reporters[SUCCESS].call; redirecters[SUCCESS].call(response) },
      CANCEL => ->(response) { analytics_reporters[CANCEL].call(response); idp_selection_reporters[CANCEL].call; redirecters[CANCEL].call(response) },
      FAILED_UPLIFT => ->(response) { analytics_reporters[FAILED_UPLIFT].call(response); idp_selection_reporters[FAILED_UPLIFT].call; redirecters[FAILED_UPLIFT].call(response) },
      PENDING => ->(response) { analytics_reporters[PENDING].call(response); idp_selection_reporters[PENDING].call; redirecters[PENDING].call(response) }
    }
    handlers.default = ->(response) { analytics_reporters[OTHER].call(response); idp_selection_reporters[FAILED].call; redirecters[OTHER].call(response) }

    handlers
  end

  def country_response_handlers
    handlers = {
      SUCCESS => redirecters[SUCCESS],
      CANCEL => redirecters[FAILED],
      FAILED_UPLIFT => redirecters[FAILED_UPLIFT]
    }
    handlers.default = redirecters[OTHER]

    handlers
  end

  def analytics_reporters
    user_state = ->(response) { response.is_registration ? REGISTERING_STATE : SIGNING_IN_STATE }

    {
      SUCCESS => ->(response) { report_to_analytics("Success - #{user_state.call(response)} at LOA #{response.loa_achieved}") },
      CANCEL  => ->(response) { report_to_analytics("Cancel - #{user_state.call(response)}") },
      FAILED_UPLIFT => ->(response) { report_to_analytics("Failed Uplift - #{user_state.call(response)}") },
      PENDING => ->(response) { report_to_analytics("Paused - #{user_state.call(response)}") },
      OTHER => ->(response) { report_to_analytics("Failure - #{user_state.call(response)}") }
    }
  end

  def idp_selection_reporters
    selected_idp = session[:selected_idp].nil? ? nil : session[:selected_idp].fetch('entity_id', nil)

    {
      SUCCESS => ->() { set_journey_hint_by_status(selected_idp, SUCCESS) },
      CANCEL  => ->() { set_journey_hint_by_status(selected_idp, CANCEL) },
      FAILED_UPLIFT => ->() { set_journey_hint_by_status(selected_idp, FAILED_UPLIFT) },
      PENDING => ->() { set_journey_hint_by_status(selected_idp, PENDING) },
      FAILED => ->() { set_journey_hint_by_status(selected_idp, FAILED) }
    }
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
