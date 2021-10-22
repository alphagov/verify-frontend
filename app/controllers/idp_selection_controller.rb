require "partials/journey_hinting_partial_controller"
require "partials/analytics_cookie_partial_controller"

class IdpSelectionController < ApplicationController
  include JourneyHintingPartialController
  include AnalyticsCookiePartialController

protected

  def register_idp_selection_in_session(entity_id)
    return something_went_wrong("No IDP entity ID present", :bad_request) if !entity_id || entity_id.empty?

    select_viewable_idp(entity_id) do |decorated_idp|
      return something_went_wrong("Couldn't display IDP with entity id: #{entity_id}", :not_found) unless decorated_idp.viewable?

      POLICY_PROXY.select_idp(session[:verify_session_id],
                              decorated_idp.entity_id,
                              session[:requested_loa],
                              is_registration_journey?,
                              persistent_session_id,
                              session[:journey_type],
                              ab_test_with_alternative_name)

      set_attempt_journey_hint decorated_idp.entity_id
      set_journey_hint_followed decorated_idp.entity_id
      session[:selected_idp_name] = decorated_idp.display_name
      report_user_idp_attempt_to_piwik

      yield decorated_idp
    end
  end

  def redirect_to_idp(uuid = nil)
    @request = request_form(uuid)
    render "shared/redirect_to_idp"
  end

  def ajax_idp_redirection_request(uuid = nil)
    yield if block_given?
    render json: request_form(uuid)
  end

  def request_form(uuid = nil)
    saml_message = SAML_PROXY_API.authn_request(session[:verify_session_id])
    IdentityProviderRequest.new(saml_message, uuid)
  end

  def set_journey_hint_followed(entity_id)
    session[:user_followed_journey_hint] = user_followed_journey_hint(entity_id) if has_journey_hint?
  end

  def has_journey_hint?
    !success_entity_id.nil?
  end

private

  def report_user_idp_attempt_to_piwik
    increase_attempt_number

    FEDERATION_REPORTER.report_user_idp_attempt(
      current_transaction: current_transaction,
      request: request,
      idp_name: session[:selected_idp_name],
      attempt_number: session[:attempt_number],
      journey_type: session[:journey_type],
      hint_followed: session[:user_followed_journey_hint],
      )
  end

  def increase_attempt_number
    session[:attempt_number] = 0 if session[:attempt_number].nil?
    session[:attempt_number] = session[:attempt_number] + 1
  end

  def is_registration_journey?
    [JourneyType::REGISTRATION, JourneyType::RESUMING].include? session[:journey_type]
  end
end
