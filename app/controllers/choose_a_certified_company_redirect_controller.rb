require "partials/idp_selection_partial_controller"
require "partials/analytics_cookie_partial_controller"

class ChooseACertifiedCompanyRedirectController < ApplicationController
  include IdpSelectionPartialController
  include AnalyticsCookiePartialController
  include ViewableIdpPartialController

  SELECTED_IDP_HISTORY_LENGTH = 5
  helper_method :other_ways_description

  def do_redirect(idp)
    if idp.viewable? && idp_is_providing_registrations?(idp)
      select_registration(idp)
      redirect_to redirect_to_idp_register_path
    else
      something_went_wrong("Couldn't display IDP with entity id: #{idp.entity_id}")
    end
  end

  def recommended
    if session.fetch(:selected_idp_was_recommended)
      "(recommended)"
    else
      "(not recommended)"
    end
  rescue KeyError
    "(idp recommendation key not set)"
  end

  def idp_is_providing_registrations?(idp)
    current_available_identity_providers_for_registration.any? { |check_idp| check_idp.simple_id == idp.simple_id }
  end

  def other_ways_description
    @other_ways_description = current_transaction.other_ways_description
  end

private

  def select_registration(idp)
    POLICY_PROXY.select_idp(session[:verify_session_id],
                            idp.entity_id,
                            session[:requested_loa],
                            true,
                            persistent_session_id,
                            session[:journey_type],
                            ab_test_with_alternative_name)
    set_journey_hint_followed(idp.entity_id)
    set_attempt_journey_hint(idp.entity_id)
    register_idp_selections(idp.display_name)
  end

  def register_idp_selections(idp_name)
    session[:selected_idp_name] = idp_name
    selected_idp_names = session[:selected_idp_names] || []
    if selected_idp_names.size < SELECTED_IDP_HISTORY_LENGTH
      selected_idp_names << idp_name
      session[:selected_idp_names] = selected_idp_names
    end
  end
end
