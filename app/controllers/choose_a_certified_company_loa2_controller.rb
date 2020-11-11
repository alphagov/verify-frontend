require "partials/viewable_idp_partial_controller"
require "partials/variant_partial_controller"
class ChooseACertifiedCompanyLoa2Controller < ChooseACertifiedCompanyRedirectController
  include ChooseACertifiedCompanyAbout
  include ViewableIdpPartialController
  include VariantPartialController

  skip_before_action :render_cross_gov_ga, only: %i{about}

  def index
    session[:selected_answers]&.delete("interstitial")
    idps = current_available_identity_providers_for_registration_loa2(current_transaction_entity_id)
    suggestions = IDP_RECOMMENDATION_ENGINE.get_suggested_idps_for_registration(idps, selected_evidence, current_transaction_simple_id)
    @recommended_idps = order_with_unavailable_last(IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate_collection(suggestions[:recommended]))
    @non_recommended_idps = order_with_unavailable_last(IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate_collection(suggestions[:unlikely]))
    FEDERATION_REPORTER.report_number_of_idps_recommended(current_transaction, request, @recommended_idps.length)

    idps_available = IDP_RECOMMENDATION_ENGINE.any?(idps, selected_evidence, current_transaction_simple_id)
    if idps_available
      session[:user_segments] = suggestions[:user_segments]
      render "choose_a_certified_company/choose_a_certified_company_LOA2"
    else
      redirect_to select_documents_advice_path
    end
  end

  def select_idp
    return render "errors/something_went_wrong", status: 400 unless params[:entity_id].present?

    select_viewable_idp_for_registration(params.fetch("entity_id")) do |decorated_idp|
      session[:selected_idp_was_recommended] = IDP_RECOMMENDATION_ENGINE.recommended?(decorated_idp.identity_provider, current_available_identity_providers_for_sign_in, selected_evidence, current_transaction_simple_id)
      # TODO - do the spinny thing page
      do_redirect(decorated_idp)
    end
  end
end
