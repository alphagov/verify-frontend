class SignInController < ApplicationController
  UNDETERMINED_IP = '<PRINCIPAL IP ADDRESS COULD NOT BE DETERMINED>'
  skip_before_action :verify_authenticity_token, only: [:select_idp]

  def index
    @identity_providers = identity_provider_lister.list(cookies)
    render 'index'
  end

  def select_idp
    originating_ip = request.headers.fetch("X-Forwarded-For", UNDETERMINED_IP)
    entity_id = params.fetch('selected-idp')
    select_idp_response = SESSION_PROXY.select_idp(cookies, entity_id, originating_ip)
    cookies[CookieNames::VERIFY_JOURNEY_HINT] = select_idp_response.encrypted_entity_id
    cvar = Analytics::CustomVariable.build(:select_idp, entity_id)
    ANALYTICS_REPORTER.report_custom_variable(request, "Sign In - #{entity_id}", cvar)
    redirect_to redirect_to_idp_path
  end
end
