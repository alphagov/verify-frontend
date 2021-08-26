# frozen_string_literal: true

require "partials/user_cookies_partial_controller"
require "partials/analytics_cookie_partial_controller"

class AuthnResponseController < SamlController
  include AnalyticsCookiePartialController

  protect_from_forgery except: %i[idp_response]

  SIGNING_IN_STATE = "SIGN_IN_WITH_IDP"
  REGISTERING_STATE = "REGISTER_WITH_IDP"
  RESUMING_STATE = "RESUME_WITH_IDP"
  SINGLE_IDP_STATE = "SINGLE_IDP"
  SUCCESS = "SUCCESS"
  MATCHING_JOURNEY_SUCCESS = "MATCHING_JOURNEY_SUCCESS"
  NON_MATCHING_JOURNEY_SUCCESS = "NON_MATCHING_JOURNEY_SUCCESS"
  CANCEL = "CANCEL"
  FAILED = "FAILED"
  FAILED_UPLIFT = "FAILED_UPLIFT"
  PENDING = "PENDING"
  OTHER = "OTHER"

  ACCEPTED_IDP_RESPONSES = [SUCCESS, MATCHING_JOURNEY_SUCCESS, NON_MATCHING_JOURNEY_SUCCESS, CANCEL, FAILED_UPLIFT, PENDING].freeze

  def idp_response
    raise_error_if_params_invalid(params, session[:verify_session_id])

    response = SAML_PROXY_API.idp_authn_response(session[:verify_session_id], params["SAMLResponse"], persistent_session_id, session[:journey_type])
    status = response.idp_result
    remove_resume_link_journey_hint unless journey_hint_value.nil?

    return handle_idp_response(status, response) if ACCEPTED_IDP_RESPONSES.include?(status)

    logger.info("IDP response status of '#{status}' for session ID '#{session[:verify_session_id]}' not in "\
      "accepted IDP response statuses. Falling back to 'FAILED'")
    handle_idp_response(FAILED, response)
  end

private

  def raise_error_if_params_invalid(response_params, session_id)
    raise Errors::WarningLevelError, "Empty IDP response" if response_params.empty?

    relay_state = response_params["RelayState"]
    error_message = "Relay state should match session id. Relay state was #{relay_state.inspect}"
    error_message += " and SAML was missing" unless response_params.key?("SAMLResponse")
    raise Errors::WarningLevelError, error_message if relay_state != session_id
  end

  def handle_idp_response(status, response)
    store_assertion_expiry(status, response)
    analytics_reporters(status, response)
    set_journey_status(status)
    clear_single_idp_cookie
    redirect_to idp_redirects(status, response)
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
      MATCHING_JOURNEY_SUCCESS => "Success Matching Journey - #{user_state(response)} at LOA #{response.loa_achieved}",
      NON_MATCHING_JOURNEY_SUCCESS => "Success Non Matching Journey - #{user_state(response)} at LOA #{response.loa_achieved}",
      CANCEL => "Cancel - #{user_state(response)}",
      FAILED_UPLIFT => "Failed Uplift - #{user_state(response)}",
      PENDING => "Paused - #{user_state(response)}",
      FAILED => "Failure - #{user_state(response)}",
    }.fetch(status)
  end

  def user_state(response)
    return REGISTERING_STATE if response.is_registration

    case session[:journey_type]
    when JourneyType::RESUMING
      RESUMING_STATE
    when JourneyType::SINGLE_IDP
      SINGLE_IDP_STATE
    else
      SIGNING_IN_STATE
    end
  end

  def path_for_success(is_registration)
    is_registration || is_journey_type?(JourneyType::SINGLE_IDP) ? confirmation_path : response_processing_path
  end

  def path_for_success_non_matching(is_registration)
    is_registration || is_journey_type?(JourneyType::SINGLE_IDP) ? confirmation_non_matching_journey_path : redirect_to_service_signing_in_path
  end

  def idp_redirects(status, response)
    is_registration = response.is_registration
    {
      SUCCESS => path_for_success(is_registration),
      MATCHING_JOURNEY_SUCCESS => path_for_success(is_registration),
      NON_MATCHING_JOURNEY_SUCCESS => path_for_success_non_matching(is_registration),
      CANCEL => is_registration ? cancelled_registration_path : start_path,
      FAILED_UPLIFT => failed_uplift_path,
      PENDING => paused_registration_path,
      FAILED => failed_page_redirects(is_registration),
    }.fetch(status)
  end

  def failed_page_redirects(is_registration)
    if is_registration || is_journey_type?(JourneyType::SINGLE_IDP)
      failed_registration_path
    else
      failed_sign_in_path
    end
  end

  def is_journey_type?(journey_type)
    session[:journey_type] == journey_type
  end

  def clear_single_idp_cookie
    cookies.delete CookieNames::VERIFY_SINGLE_IDP_JOURNEY
  end

  def store_assertion_expiry(status, response)
    session[:assertion_expiry] = response.assertion_expiry if status == SUCCESS
  end
end
