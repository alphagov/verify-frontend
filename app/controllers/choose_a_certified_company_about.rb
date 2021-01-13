require "partials/viewable_idp_partial_controller"

module ChooseACertifiedCompanyAbout
  include ViewableIdpPartialController

  def about
    simple_id = params[:company]
    matching_idp = current_available_identity_providers_for_registration.detect { |idp| idp.simple_id == simple_id }
    @idp = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate(matching_idp)
    if @idp.viewable?
      render "choose_a_certified_company/about"
    else
      render "errors/404", status: 404
    end
  end
end
