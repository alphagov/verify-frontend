class SignInController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:select_idp]

  def index
    federation_info = SESSION_PROXY.federation_info_for_session(cookies)

    @identity_providers = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate(federation_info.idps)

    FEDERATION_REPORTER.report_sign_in(federation_info.transaction_simple_id, request)
    render 'index'
  end

  def select_idp
    entity_id = params.fetch('selected-idp-entity-id') { params.fetch('selected-idp') }
    display_name = params.fetch('selected-idp-display-name', entity_id)
    select_idp_response = SESSION_PROXY.select_idp(cookies, entity_id)
    set_secure_cookie(CookieNames::VERIFY_JOURNEY_HINT, select_idp_response.encrypted_entity_id)
    cvar = Analytics::CustomVariable.build(:select_idp, display_name)
    ANALYTICS_REPORTER.report_custom_variable(request, "Sign In - #{display_name}", cvar)
    redirect_to redirect_to_idp_path
  end
end
