class RedirectToIdpController < ApplicationController
  UNDETERMINED_IP = '<PRINCIPAL IP ADDRESS COULD NOT BE DETERMINED>'

  def index
    originating_ip = request.headers.fetch("X-Forwarded-For", UNDETERMINED_IP)
    response = SESSION_PROXY.idp_authn_request(cookies, originating_ip)
    @location = response['location']
    @saml_request = response['samlRequest']
    @relay_state = response['relayState']
    @registration = response['registration']
  end
end
