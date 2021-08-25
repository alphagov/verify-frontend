require "partials/viewable_idp_partial_controller"
class ChooseACertifiedCompanyLoa1Controller < ChooseACertifiedCompanyRedirectController
  include ChooseACertifiedCompanyAbout
  include ViewableIdpPartialController

  skip_before_action :render_cross_gov_ga, only: %i{about}

  def index
    @recommended_idps = order_with_unavailable_last(IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate_collection(current_available_identity_providers_for_registration))
    FEDERATION_REPORTER.report_number_of_idps_recommended(current_transaction, request, @recommended_idps.length)

    @show_non_recommended_idps = false
    render "choose_a_certified_company/choose_a_certified_company"
  end

  def select_idp
    return render "errors/something_went_wrong", status: 400 unless params[:entity_id].present?

    selected_answer_store.store_selected_answers("interstitial", {})
    select_viewable_idp_for_registration(params.fetch("entity_id")) do |decorated_idp|
      session[:selected_idp_was_recommended] = true
      do_redirect(decorated_idp)
    end
  end
end
