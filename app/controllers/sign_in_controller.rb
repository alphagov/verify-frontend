class SignInController < ApplicationController
  UNDETERMINED_IP = '<PRINCIPAL IP ADDRESS COULD NOT BE DETERMINED>'
  def index
    @identity_providers = identity_provider_lister.list(cookies)
    render 'index'
  end

  def identity_provider_lister
    IDENTITY_PROVIDER_LISTER
  end

  def select_idp
    originating_ip = request.headers.fetch("X-Forwarded-For", UNDETERMINED_IP)
    SESSION_PROXY.select_idp(cookies, params.fetch('selected-idp'), originating_ip)
    redirect_to redirect_to_idp_path
  end
end
