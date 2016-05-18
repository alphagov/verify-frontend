class SignInController < ApplicationController
  def index
    @identity_providers = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate_collection(
      SESSION_PROXY.identity_providers(cookies)
    )

    FEDERATION_REPORTER.report_sign_in(current_transaction_simple_id, request)
    render 'index'
  end

  def select_idp
    entity_id = params.fetch('selected-idp-entity-id') { params.fetch('selected-idp') }
    display_name = params.fetch('selected-idp-display-name', entity_id)
    sign_in(entity_id, display_name)
    if params.has_key? 'identity_provider'
      session[:selected_idp] = IdentityProvider.new(params.fetch('identity_provider'))
    end
    redirect_to redirect_to_idp_path
  end

  def select_idp_ajax
    sign_in(params.fetch('entityId'), params.fetch('displayName'))
    authn_request_json = SESSION_PROXY.idp_authn_request(cookies)
    if params.has_key? 'simpleId'
      session[:selected_idp] = IdentityProvider.new('simple_id' => params.fetch('simpleId'), 'entity_id' => params.fetch('entityId'))
    end
    render json: authn_request_json
  end

private

  def sign_in(entity_id, display_name)
    SESSION_PROXY.select_idp(cookies, entity_id)
    set_journey_hint(entity_id, I18n.locale)
    cvar = Analytics::CustomVariable.build(:select_idp, display_name)
    ANALYTICS_REPORTER.report_custom_variable(request, "Sign In - #{display_name}", cvar)
  end
end
