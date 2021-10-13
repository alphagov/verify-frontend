require "partials/idp_selection_partial_controller"
require "partials/single_idp_partial_controller"
require "partials/analytics_cookie_partial_controller"
require "partials/viewable_idp_partial_controller"

class RedirectToIdpController < ApplicationController
  include IdpSelectionPartialController
  include SingleIdpPartialController
  include AnalyticsCookiePartialController
  include ViewableIdpPartialController

  def register
    request_form
    increase_attempt_number
    report_user_idp_attempt_to_piwik
    report_idp_registration_to_piwik
    render :redirect_to_idp
  end

  def sign_in
    request_form
    increase_attempt_number
    report_user_idp_attempt_to_piwik
    if session[:user_followed_journey_hint].nil?
      FEDERATION_REPORTER.report_sign_in_idp_selection(current_transaction, request, session[:selected_idp_name])
    else
      FEDERATION_REPORTER.report_sign_in_idp_selection_after_journey_hint(current_transaction, request, session[:selected_idp_name], session[:user_followed_journey_hint])
    end
    render :redirect_to_idp
  end

  def resume
    request_form
    increase_attempt_number
    report_user_idp_attempt_to_piwik
    FEDERATION_REPORTER.report_idp_resume_journey_selection(current_transaction, request, session[:selected_idp_name])
    render :redirect_to_idp
  end

  def single_idp
    if valid_cookie?
      uuid = MultiJson.load(cookies.encrypted[CookieNames::VERIFY_SINGLE_IDP_JOURNEY]).fetch("uuid", nil)
      request_form_for_single_idp_journey(uuid)
      increase_attempt_number
      report_user_idp_attempt_to_piwik
      FEDERATION_REPORTER.report_single_idp_journey_selection(current_transaction, request, session[:selected_idp_name])
      render :redirect_to_idp
    else
      render_error :session_error, :bad_request
    end
  end

private

  def request_form
    saml_message = SAML_PROXY_API.authn_request(session[:verify_session_id])
    @request = idp_request_initialisation(saml_message)
  end

  def request_form_for_single_idp_journey(uuid)
    saml_message = SAML_PROXY_API.authn_request(session[:verify_session_id])
    @request = idp_request_initialisation_for_single_idp_journey(saml_message, uuid)
  end

  def select_idp(entity_id, idp_name)
    POLICY_PROXY.select_idp(session[:verify_session_id],
                            entity_id,
                            session[:requested_loa],
                            false,
                            persistent_session_id,
                            session[:journey_type],
                            ab_test_with_alternative_name)
    set_attempt_journey_hint(entity_id)
    session[:selected_idp_name] = idp_name
  end
end
