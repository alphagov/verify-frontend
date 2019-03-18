require 'partials/viewable_idp_partial_controller'

class CertifiedCompanyUnavailableController < ApplicationController
  include ViewableIdpPartialController

  def index
    simple_id = params[:company]

    if UNAVAILABLE_IDPS.include?(simple_id) && !current_available_identity_providers_for_sign_in.map(&:simple_id).include?(simple_id)
      @idp = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate(
        IdentityProvider.new('simpleId' => simple_id, 'entityId' => simple_id, 'levelsOfAssurance' => [])
      )
      @other_ways_description = current_transaction.other_ways_description
      @other_ways_text = current_transaction.other_ways_text
      render 'index'
    else
      render 'errors/404', status: 404
    end
  end
end
