# frozen_string_literal: true

require 'partials/user_cookies_partial_controller'

class AuthnResponseController < SamlController
  protect_from_forgery except: %i[idp_response country_response]

  SIGNING_IN_STATE = 'SIGN_IN_WITH_IDP'
  REGISTERING_STATE = 'REGISTER_WITH_IDP'
  RESUMING_STATE = 'RESUME_WITH_IDP'
  SINGLE_IDP_STATE = 'SINGLE_IDP'
  SUCCESS = 'SUCCESS'
  CANCEL = 'CANCEL'
  FAILED = 'FAILED'
  FAILED_UPLIFT = 'FAILED_UPLIFT'
  PENDING = 'PENDING'
  OTHER = 'OTHER'
  SINGLE_IDP_JOURNEY_TYPE = 'single-idp'
  RESUMING_JOURNEY_TYPE = 'resuming'

  ACCEPTED_IDP_RESPONSES = [SUCCESS, CANCEL, FAILED_UPLIFT, PENDING].freeze
  ACCEPTED_COUNTRY_RESPONSES = [SUCCESS, CANCEL, FAILED_UPLIFT].freeze

  def idp_response
    raise_error_if_session_mismatch(params['RelayState'], session[:verify_session_id])

    response = SAML_PROXY_API.idp_authn_response(session[:verify_session_id], params['SAMLResponse'])
    status = response.idp_result

    return handle_idp_response(status, response) if ACCEPTED_IDP_RESPONSES.include?(status)
    handle_idp_response(FAILED, response)
  end

  def country_response
    params['RelayState'] ||= session[:verify_session_id] if session[:transaction_supports_eidas]
    raise_error_if_session_mismatch(params['RelayState'], session[:verify_session_id])

    response = SAML_PROXY_API.forward_country_authn_response(params['RelayState'], params['SAMLResponse'])
    status = response.country_result

    return handle_country_response(status, response) if ACCEPTED_COUNTRY_RESPONSES.include?(status)
    handle_country_response(FAILED, response)
  end

private

  def raise_error_if_session_mismatch(relay_state, session_id)
    error_message = "Relay state should match session id. Relay state was #{relay_state.inspect}"
    raise Errors::WarningLevelError, error_message if relay_state != session_id
  end

  def handle_idp_response(status, response)
    analytics_reporters(status, response)
    set_journey_status(status)
    redirect_to idp_redirects(status, response)
  end

  def handle_country_response(status, response)
    redirect_to country_redirects(status, response)
  end

  def analytics_reporters(status, response)
    report_to_analytics(analytics_message(status, response))
    report_user_outcome_to_piwik(status)
  end

  def set_journey_status(status)
    selected_entity = selected_identity_provider.entity_id
    set_journey_hint_by_status(selected_entity, status)
  end

  def analytics_message(status, response)
    {
      SUCCESS => "Success - #{user_state(response)} at LOA #{response.loa_achieved}",
      CANCEL => "Cancel - #{user_state(response)}",
      FAILED_UPLIFT => "Failed Uplift - #{user_state(response)}",
      PENDING => "Paused - #{user_state(response)}",
      FAILED => "Failure - #{user_state(response)}"
    }.fetch(status)
  end

  def user_state(response)
    return REGISTERING_STATE if response.is_registration
    case session[:journey_type]
    when RESUMING_JOURNEY_TYPE
      RESUMING_STATE
    when SINGLE_IDP_JOURNEY_TYPE
      SINGLE_IDP_STATE
    else
      SIGNING_IN_STATE
    end
  end

  def idp_redirects(status, response)
    is_registration = response.is_registration
    {
      SUCCESS => is_registration ? confirmation_path : response_processing_path,
      CANCEL => is_registration ? cancelled_registration_path : start_path,
      FAILED_UPLIFT => failed_uplift_path,
      PENDING => paused_registration_path,
      FAILED => failed_page_redirects(is_registration)
    }.fetch(status)
  end

  def failed_page_redirects(is_registration)
    if is_registration || journey_type?(SINGLE_IDP_JOURNEY_TYPE)
      failed_registration_path
    else
      failed_sign_in_path
    end
  end

  def journey_type?(journey_type)
    session[:journey_type] == journey_type
  end

  def country_redirects(status, response)
    is_registration = response.is_registration
    {
      SUCCESS => is_registration ? confirmation_path : response_processing_path,
      CANCEL => is_registration ? failed_registration_path : start_path,
      FAILED_UPLIFT => failed_uplift_path,
      FAILED => is_registration ? failed_registration_path : failed_country_sign_in_path
    }.fetch(status)
  end
end
