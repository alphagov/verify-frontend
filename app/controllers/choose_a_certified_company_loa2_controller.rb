require "partials/viewable_idp_partial_controller"

class ChooseACertifiedCompanyLoa2Controller < ChooseACertifiedCompanyRedirectController
  include ChooseACertifiedCompanyAbout
  include ViewableIdpPartialController

  skip_before_action :render_cross_gov_ga, only: %i{about}

  def index
    session[:selected_answers]&.delete("interstitial")
    idps = current_available_identity_providers_for_registration
    suggestions = IDP_RECOMMENDATION_ENGINE.get_suggested_idps_for_registration(idps, selected_evidence, current_transaction_simple_id)
    @recommended_idps = order_with_unavailable_last(IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate_collection(suggestions[:recommended]))
    @non_recommended_idps = order_with_unavailable_last(IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate_collection(suggestions[:unlikely]))
    FEDERATION_REPORTER.report_number_of_idps_recommended(current_transaction, request, @recommended_idps.length)

    if @recommended_idps.any?
      @show_non_recommended_idps = true
      session[:user_segments] = suggestions[:user_segments]
      render "choose_a_certified_company/index"
    else
      redirect_to no_idps_available_path
    end
  end

  def select_idp
    return render "errors/something_went_wrong", status: 400 unless params[:entity_id].present?

    select_viewable_idp_for_registration(params.fetch("entity_id")) do |decorated_idp|
      session[:selected_idp_was_recommended] = IDP_RECOMMENDATION_ENGINE.recommended?(
        decorated_idp.identity_provider,
        current_available_identity_providers_for_registration,
        selected_evidence,
        current_transaction_simple_id,
      )

      # TODO - do the spinny thing page
      do_redirect(decorated_idp)
    end
  end
end
