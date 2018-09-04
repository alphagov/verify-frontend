require 'partials/idp_selection_partial_controller'

class RedirectToIdpController < ApplicationController
  include IdpSelectionPartialController

  def register
    request_form
    increase_attempt_number
    report_user_idp_attempt_to_piwik
    report_idp_registration_to_piwik(recommended)
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

  def single_idp
    uuid = MultiJson.load(cookies.encrypted[CookieNames::VERIFY_SINGLE_IDP_JOURNEY]).fetch('uuid', nil)
    request_form_for_single_idp_journey(uuid)
    increase_attempt_number
    report_user_idp_attempt_to_piwik
    FEDERATION_REPORTER.report_single_idp_journey_selection(current_transaction, request, session[:selected_idp_name])
    render :redirect_to_idp
  end

private

  def request_form
    saml_message = SAML_PROXY_API.authn_request(session[:verify_session_id])
    @request = idp_request_initilization(saml_message)
  end

  def request_form_for_single_idp_journey(uuid)
    saml_message = SAML_PROXY_API.authn_request(session[:verify_session_id])
    @request = idp_request_initilization_for_single_idp_journey(saml_message, uuid)
  end

  def recommended
    begin
      if session.fetch(:selected_idp_was_recommended)
        '(recommended)'
      else
        '(not recommended)'
      end
    rescue KeyError
      '(idp recommendation key not set)'
    end
  end
end
