require 'partials/viewable_idp_partial_controller'
require 'partials/variant_partial_controller'

class ChooseACertifiedCompanyLoa2VariantCController < RedirectToIdpWarningController
  include ChooseACertifiedCompanyAbout
  include ViewableIdpPartialController
  include VariantPartialController

  skip_before_action :render_cross_gov_ga, only: %i{about}

  def index
    session[:selected_answers]&.delete('interstitial')
    idps = current_identity_providers_for_loa_by_variant('c')
    suggestions = recommendation_engine.get_suggested_idps(idps, selected_evidence, current_transaction_simple_id)
    @recommended_idps = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate_collection(suggestions[:recommended])
    @recommended_idps = order_with_unavailable_last(@recommended_idps)
    @non_recommended_idps = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate_collection(suggestions[:unlikely])
    @non_recommended_idps = order_with_unavailable_last(@non_recommended_idps)
    FEDERATION_REPORTER.report_number_of_idps_recommended(current_transaction, request, @recommended_idps.length)

    idps_available = IDP_RECOMMENDATION_ENGINE_variant_c.any?(idps, selected_evidence, current_transaction_simple_id)
    if idps_available
      session[:user_segments] = suggestions[:user_segments]
      render 'choose_a_certified_company_variant_c/choose_a_certified_company_LOA2'
    else
      redirect_to select_documents_advice_path
    end
  end

  def select_idp
    if params[:entity_id].present?
      select_viewable_idp_for_loa(params.fetch('entity_id')) do |decorated_idp|
        session[:selected_idp_was_recommended] = recommendation_engine.recommended?(decorated_idp.identity_provider, current_identity_providers_for_loa_by_variant('c'), selected_evidence, current_transaction_simple_id)
        # TODO - do the spinny thing page
        do_redirect(decorated_idp)
      end
    else
      render 'errors/something_went_wrong', status: 400
    end
  end

private

  def do_redirect(idp)
    if not_more_than_one_uk_doc_selected && interstitial_question_flag_enabled_for(idp)
      redirect_to redirect_to_idp_question_path
    elsif idp.viewable?
      select_registration(idp)
      redirect_to redirect_to_idp_register_path
    else
      something_went_wrong("Couldn't display IDP with entity id: #{idp.entity_id}")
    end
  end

  def not_more_than_one_uk_doc_selected
    (%i[passport driving_licence] & selected_evidence).size <= 1
  end

  def interstitial_question_flag_enabled_for(decorated_idp)
    IDP_FEATURE_FLAGS_CHECKER.enabled?(:show_interstitial_question, decorated_idp.simple_id)
  end

  def recommendation_engine
    IDP_RECOMMENDATION_ENGINE_variant_c
  end
end
