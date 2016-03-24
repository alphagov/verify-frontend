class SignInController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:select_idp]

  def index
    federation_info = FEDERATION_INFO_GETTER.get_info(cookies)
    @identity_providers = federation_info[:idp_display_data]
    cvar = Analytics::CustomVariable.build(:rp, federation_info[:transaction_entity_id])
    ANALYTICS_REPORTER.report_custom_variable(request, 'The No option was selected on the introduction page', cvar)
    render 'index'
  end

  def select_idp
    entity_id = params.fetch('selected-idp')
    select_idp_response = SESSION_PROXY.select_idp(cookies, entity_id)
    cookies[CookieNames::VERIFY_JOURNEY_HINT] = select_idp_response.encrypted_entity_id
    cvar = Analytics::CustomVariable.build(:select_idp, entity_id)
    ANALYTICS_REPORTER.report_custom_variable(request, "Sign In - #{entity_id}", cvar)
    redirect_to redirect_to_idp_path
  end
end
