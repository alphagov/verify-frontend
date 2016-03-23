class RedirectToIdpController < ApplicationController
  def index
    @saml_message = SESSION_PROXY.idp_authn_request(cookies)
  end
end
