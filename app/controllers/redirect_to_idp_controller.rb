class RedirectToIdpController < ApplicationController
  UNDETERMINED_IP = '<PRINCIPAL IP ADDRESS COULD NOT BE DETERMINED>'

  def index
    originating_ip = request.headers.fetch("X-Forwarded-For", UNDETERMINED_IP)
    @saml_message = SESSION_PROXY.idp_authn_request(cookies, originating_ip)
  end
end
