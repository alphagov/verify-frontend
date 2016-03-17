class AboutController < ApplicationController
  layout 'start'

  def index
  end

  def certified_companies
    @identity_providers = identity_provider_lister.list(cookies)
  end
end
