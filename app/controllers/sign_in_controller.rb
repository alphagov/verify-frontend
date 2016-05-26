class SignInController < ApplicationController
  def index
    @identity_providers = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate_collection(
      current_identity_providers
    )

    FEDERATION_REPORTER.report_sign_in(current_transaction_simple_id, request)
    render 'index'
  end

  def select_idp
    idp_form = params.fetch('identity_provider')
    idp = IdentityProvider.new(idp_form)
    display_name = idp_form.fetch('display_name', idp.entity_id)
    sign_in(idp.entity_id, display_name)
    session[:selected_idp] = idp
    redirect_to redirect_to_idp_path
  end

  def select_idp_ajax
    sign_in(params.fetch('entityId'), params.fetch('displayName'))
    authn_request_json = SESSION_PROXY.idp_authn_request(cookies)
    session[:selected_idp] = IdentityProvider.new('simple_id' => params.fetch('simpleId'), 'entity_id' => params.fetch('entityId'))
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
