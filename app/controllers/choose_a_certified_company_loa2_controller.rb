require "partials/viewable_idp_partial_controller"

class ChooseACertifiedCompanyLoa2Controller < ChooseACertifiedCompanyRedirectController
  include ChooseACertifiedCompanyAbout
  include ViewableIdpPartialController

  skip_before_action :render_cross_gov_ga, only: %i{about}

  def index
    idps = identity_providers_available_for_registration
    @recommended_idps = order_with_unavailable_last(IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate_collection(idps))
    return something_went_wrong("No IDPs available for registration") unless @recommended_idps.any?

    render "choose_a_certified_company/choose_a_certified_company"
  end

  def select_idp
    return render "errors/something_went_wrong", status: 400 unless params[:entity_id].present?

    select_viewable_idp_for_registration(params.fetch("entity_id")) do |decorated_idp|
      # TODO - do the spinny thing page
      do_redirect(decorated_idp)
    end
  end
end
