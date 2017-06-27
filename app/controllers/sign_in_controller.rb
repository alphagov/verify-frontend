class SignInController < ApplicationController
  def index
    @identity_providers = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate_collection(
      current_identity_providers
    )

    @unavailable_identity_providers = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate_collection(
      unavailable_idps.map { |simple_id| IdentityProvider.new('simpleId' => simple_id, 'entityId' => simple_id, 'levelsOfAssurance' => []) }
    )

    FEDERATION_REPORTER.report_sign_in(current_transaction, request)
    FEDERATION_REPORTER.report_loa_requested(request, session[:requested_loa])
    render 'index'
  end

  def select_idp
    select_viewable_idp(params.fetch('entity_id')) do |decorated_idp|
      sign_in(decorated_idp.entity_id, decorated_idp.display_name)
      redirect_to redirect_to_idp_path
    end
  end

  def select_idp_ajax
    select_viewable_idp(params.fetch('entityId')) do |decorated_idp|
      sign_in(decorated_idp.entity_id, decorated_idp.display_name)
      outbound_saml_message = SESSION_PROXY.idp_authn_request(session[:verify_session_id])
      provider_request = IdentityProviderRequest.new(
        outbound_saml_message,
        selected_identity_provider.simple_id,
        selected_answer_store.selected_answers
      )
      render json: provider_request
    end
  end

private

  def sign_in(entity_id, display_name)
    SESSION_PROXY.select_idp(session[:verify_session_id], entity_id)
    set_journey_hint(entity_id)
    FEDERATION_REPORTER.report_sign_in_idp_selection(request, display_name)
  end

  def unavailable_idps
    api_idp_simple_ids = current_identity_providers.map(&:simple_id)
    UNAVAILABLE_IDPS.reject { |simple_id| api_idp_simple_ids.include?(simple_id) }
  end
end
