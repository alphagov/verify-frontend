class SignInController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:select_idp]

  def index
    federation_info = FEDERATION_INFO_GETTER.get_info(cookies)
    @identity_providers = federation_info[:idp_display_data]
    FEDERATION_REPORTER.report_sign_in(federation_info[:transaction_simple_id], request)
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
