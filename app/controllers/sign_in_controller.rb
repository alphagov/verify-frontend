require 'partials/idp_selection_partial_controller'
require 'partials/viewable_idp_partial_controller'

class SignInController < ApplicationController
  include IdpSelectionPartialController
  include ViewableIdpPartialController

  def index
    entity_id = success_entity_id
    @suggested_idp = entity_id.nil? ? [] : retrieve_decorated_singleton_idp_array_by_entity_id(current_identity_providers_for_sign_in, entity_id)
    unless @suggested_idp.empty?
      FEDERATION_REPORTER.report_sign_in_journey_hint_shown(current_transaction, request, @suggested_idp[0].display_name)
    end

    @identity_providers = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate_collection(current_identity_providers_for_sign_in)

    @unavailable_identity_providers = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate_collection(
      unavailable_idps.map { |simple_id| IdentityProvider.new('simpleId' => simple_id, 'entityId' => simple_id, 'levelsOfAssurance' => []) }
    )

    @disconnected_idps = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate_collection(current_disconnected_identity_providers_for_sign_in)

    render :index
  end

  def select_idp
    select_viewable_idp_for_sign_in(params.fetch('entity_id')) do |decorated_idp|
      set_journey_hint_followed(decorated_idp.entity_id)
      sign_in(decorated_idp.entity_id, decorated_idp.display_name)
      redirect_to redirect_to_idp_sign_in_path
    end
  end

  def select_idp_ajax
    select_viewable_idp_for_sign_in(params.fetch('entityId')) do |decorated_idp|
      sign_in(decorated_idp.entity_id, decorated_idp.display_name)
      ajax_idp_redirection_sign_in_request(decorated_idp.entity_id)
    end
  end

private

  def sign_in(entity_id, idp_name)
    POLICY_PROXY.select_idp(session[:verify_session_id], entity_id, session['requested_loa'])
    set_attempt_journey_hint(entity_id)
    session[:selected_idp_name] = idp_name
  end

  def unavailable_idps
    api_idp_simple_ids = current_identity_providers_for_sign_in.map(&:simple_id)
    UNAVAILABLE_IDPS.reject { |simple_id| api_idp_simple_ids.include?(simple_id) }
  end
end
