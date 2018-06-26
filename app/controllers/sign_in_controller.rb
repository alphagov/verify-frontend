require 'partials/idp_selection_partial_controller'
require 'partials/viewable_idp_partial_controller'

class SignInController < ApplicationController
  include IdpSelectionPartialController
  include ViewableIdpPartialController

  def index
    @identity_providers = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate_collection(current_identity_providers_for_sign_in)

    @unavailable_identity_providers = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate_collection(
      unavailable_idps.map { |simple_id| IdentityProvider.new('simpleId' => simple_id, 'entityId' => simple_id, 'levelsOfAssurance' => []) }
    )

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
      session[:user_followed_journey_hint] = user_followed_journey_hint(decorated_idp.entity_id, 'SUCCESS')
    end
  end

private

  def sign_in(entity_id, idp_name)
    if session[:journey_type] != 'sign-in'
      FEDERATION_REPORTER.report_sign_in(current_transaction, request)
      session[:journey_type] = 'sign-in'
    end
    POLICY_PROXY.select_idp(session[:verify_session_id], entity_id, session['requested_loa'])
    set_journey_hint(entity_id)
    session[:selected_idp_name] = idp_name
  end

  def unavailable_idps
    api_idp_simple_ids = current_identity_providers_for_sign_in.map(&:simple_id)
    UNAVAILABLE_IDPS.reject { |simple_id| api_idp_simple_ids.include?(simple_id) }
  end
end
