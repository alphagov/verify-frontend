class SelectIdpController < ApplicationController
  UNDETERMINED_IP = '<PRINCIPAL IP ADDRESS COULD NOT BE DETERMINED>'
  def select_idp
    SESSION_PROXY.select_idp(request.cookies, params.fetch('entityId'))
    originating_ip = request.headers.fetch("X-Forwarded-For", UNDETERMINED_IP)
    authn_request_json = SESSION_PROXY.idp_authn_request(request.cookies, originating_ip)
    render json: authn_request_json
  end
end
