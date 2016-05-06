class SelectIdpController < ApplicationController
  def select_idp
    entity_id = params.fetch('entityId')
    display_name = params.fetch('displayName')
    select_idp_response = SESSION_PROXY.select_idp(cookies, entity_id)
    cvar = Analytics::CustomVariable.build(:select_idp, display_name)
    ANALYTICS_REPORTER.report_custom_variable(request, "Sign In - #{display_name}", cvar)
    set_secure_cookie(CookieNames::VERIFY_JOURNEY_HINT, select_idp_response.encrypted_entity_id)
    set_journey_hint(entity_id, I18n.locale)
    authn_request_json = SESSION_PROXY.idp_authn_request(cookies)
    render json: authn_request_json
  end
end
