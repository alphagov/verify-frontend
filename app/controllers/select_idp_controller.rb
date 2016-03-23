class SelectIdpController < ApplicationController
  def select_idp
    entity_id = params.fetch('entityId')
    select_idp_response = SESSION_PROXY.select_idp(cookies, entity_id)
    cvar = Analytics::CustomVariable.build(:select_idp, entity_id)
    ANALYTICS_REPORTER.report_custom_variable(request, "Sign In - #{entity_id}", cvar)
    cookies[CookieNames::VERIFY_JOURNEY_HINT] = select_idp_response.encrypted_entity_id
    authn_request_json = SESSION_PROXY.idp_authn_request(cookies)
    render json: authn_request_json
  end
end
