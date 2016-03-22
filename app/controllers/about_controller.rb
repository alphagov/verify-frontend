class AboutController < ApplicationController
  layout 'start', except: [:choosing_a_company]

  def index
  end

  def certified_companies
    @identity_providers = identity_provider_lister.list(cookies, CONFIG.white_logo_directory)
  end

  def choosing_a_company
  end
end
