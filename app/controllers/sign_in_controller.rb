class SignInController < ApplicationController
  def index
    @identity_providers = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate_collection(
      current_identity_providers
    )

    @unavailable_identity_providers = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate_collection(
      unavailable_idps.map { |simple_id| IdentityProvider.new('simpleId' => simple_id, 'entityId' => simple_id, 'levelsOfAssurance' => []) }
    )

    render :index
  end

  def select_idp
    select_viewable_idp(params.fetch('entity_id')) do |decorated_idp|
      sign_in(decorated_idp.display_name)
      redirect_to redirect_to_idp_path
    end
  end

  def select_idp_ajax
    select_viewable_idp(params.fetch('entityId')) do |decorated_idp|
      sign_in(decorated_idp.entity_id)
      ajax_idp_redirection_sign_in_request(decorated_idp.display_name)
    end
  end

private

  def sign_in(entity_id)
    POLICY_PROXY.select_idp(session[:verify_session_id], entity_id)
    set_journey_hint(entity_id)
  end

  def unavailable_idps
    api_idp_simple_ids = current_identity_providers.map(&:simple_id)
    UNAVAILABLE_IDPS.reject { |simple_id| api_idp_simple_ids.include?(simple_id) }
  end
end
