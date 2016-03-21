class SelectIdpController < ApplicationController
  UNDETERMINED_IP = '<PRINCIPAL IP ADDRESS COULD NOT BE DETERMINED>'
  def select_idp
    originating_ip = request.headers.fetch("X-Forwarded-For", UNDETERMINED_IP)
    entity_id = params.fetch('entityId')
    select_idp_response = SESSION_PROXY.select_idp(cookies, entity_id, originating_ip)
    cvar = Analytics::CustomVariable.build(:select_idp, entity_id)
    ANALYTICS_REPORTER.report_custom_variable(request, "Sign In - #{entity_id}", cvar)
    cookies[CookieNames::VERIFY_JOURNEY_HINT] = select_idp_response.encrypted_entity_id
    authn_request_json = SESSION_PROXY.idp_authn_request(cookies, originating_ip)
    render json: authn_request_json
  end
end
