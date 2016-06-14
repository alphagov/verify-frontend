class SignInController < ApplicationController
  def index
    @identity_providers = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate_collection(
      current_identity_providers
    )

    FEDERATION_REPORTER.report_sign_in(current_transaction_simple_id, request)
    render 'index'
  end

  def select_idp
    for_viewable_idp(params.fetch('simple_id')) do |decorated_idp|
      sign_in(decorated_idp.entity_id, decorated_idp.display_name)
      session[:selected_idp] = decorated_idp.identity_provider
      redirect_to redirect_to_idp_path
    end
  end

  def select_idp_ajax
    for_viewable_idp(params.fetch('simpleId')) do |decorated_idp|
      sign_in(decorated_idp.entity_id, decorated_idp.display_name)
      authn_request_json = SESSION_PROXY.idp_authn_request(cookies)
      session[:selected_idp] = decorated_idp.identity_provider
      render json: authn_request_json
    end
  end

private

  def sign_in(entity_id, display_name)
    SESSION_PROXY.select_idp(cookies, entity_id)
    set_journey_hint(entity_id, I18n.locale)
    cvar = Analytics::CustomVariable.build(:select_idp, display_name)
    ANALYTICS_REPORTER.report_custom_variable(request, "Sign In - #{display_name}", cvar)
  end
end
