require 'partials/idp_selection_partial_controller'

class RedirectToIdpController < ApplicationController
  include IdpSelectionPartialController

  # TODO: HUB-114: To be removed together with segment logic once we have assessed if the new reporting works
  SEGMENT_TO_BE_TESTED = '2doc_nidl_pp_mobile_app'.freeze
  SEGMENT_FOR_TEST = 'test-segment'.freeze

  def register
    request_form
    increase_attempt_number
    report_user_idp_attempt_to_piwik if segment_should_be_reported?
    report_idp_registration_to_piwik(recommended)
    render :redirect_to_idp
  end

  def sign_in
    request_form
    if session[:user_followed_journey_hint].nil?
      FEDERATION_REPORTER.report_sign_in_idp_selection(current_transaction, request, session[:selected_idp_name])
    else
      FEDERATION_REPORTER.report_sign_in_idp_selection_after_journey_hint(current_transaction, request, session[:selected_idp_name], session[:user_followed_journey_hint])
    end
    render :redirect_to_idp
  end

private

  def segment_should_be_reported?
    return false if session[:user_segments].nil?
    session[:user_segments].include?(SEGMENT_TO_BE_TESTED) || session[:user_segments].include?(SEGMENT_FOR_TEST)
  end

  def increase_attempt_number
    session[:attempt_number] = 0 if session[:attempt_number].nil?
    session[:attempt_number] = session[:attempt_number] + 1
  end

  def request_form
    saml_message = SAML_PROXY_API.authn_request(session[:verify_session_id])
    @request = idp_request_initilization(saml_message)
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
