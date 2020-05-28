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

  def sign_in_with_last_successful_idp
    session[:journey_type] = "sign-in-last-sucessful-idp"
    simple_id = flash[:journey_hint]
    return render_not_found unless simple_id

    simple_id.slice!("idp_")

    decorated_idp = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate(
      current_available_identity_providers_for_sign_in.detect { |idp| idp.simple_id == simple_id },
    )
    if decorated_idp.viewable?
      store_selected_idp_for_session(decorated_idp.identity_provider)
      set_journey_hint_followed(decorated_idp.entity_id)
      select_idp(decorated_idp.entity_id, decorated_idp.display_name)
    else
      logger.error "Viewable IdP not found for simple ID #{simple_id}"
      return render_not_found
    end
    sign_in
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
      render_error "session_error", :bad_request
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

  def recommended
    begin
      if session.fetch(:selected_idp_was_recommended)
        "(recommended)"
      else
        "(not recommended)"
      end
    rescue KeyError
      "(idp recommendation key not set)"
    end
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
