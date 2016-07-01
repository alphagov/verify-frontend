class CertifiedCompanyUnavailableController < ApplicationController
  def index
    simple_id = params[:company]

    if UNAVAILABLE_IDPS.include?(simple_id) && !current_identity_providers.map(&:simple_id).include?(simple_id)
      @idp = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate(
        IdentityProvider.new('simple_id' => simple_id, 'entity_id' => simple_id)
      )
      render 'index'
    else
      render 'errors/404', status: 404
    end
  end
end
