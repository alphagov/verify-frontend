class SignInController < ApplicationController
  def index
    @identity_providers = identity_provider_lister.list(cookies)
    render 'index'
  end

  def identity_provider_lister
    IDENTITY_PROVIDER_LISTER
  end
end
