class SignInController < ApplicationController
  def index
    @identity_providers = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate_collection(
      current_identity_providers
    )

    FEDERATION_REPORTER.report_sign_in(current_transaction_simple_id, request)
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
      outbound_saml_message = SESSION_PROXY.idp_authn_request(cookies)
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
    SESSION_PROXY.select_idp(cookies, entity_id)
    set_journey_hint(entity_id, I18n.locale)
    FEDERATION_REPORTER.report_sign_in_idp_selection(request, display_name)
  end
end
