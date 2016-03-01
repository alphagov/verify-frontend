class SelectIdpController < ApplicationController
  def select_idp
    SESSION_PROXY.select_idp(request.cookies, params.fetch('entityId'))
    authn_request_json = SESSION_PROXY.idp_authn_request(request.cookies)
    render json: authn_request_json
  end
end
