class ChooseACertifiedCompanyLoa2Controller < ApplicationController
  include ChooseACertifiedCompanyAbout
  include ViewableIdp

  def index
    session[:selected_answers]&.delete('interstitial')
    suggestions = recommendation_engine.get_suggested_idps(current_identity_providers_for_loa, selected_evidence, current_transaction_simple_id)
    @recommended_idps = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate_collection(suggestions[:recommended])
    @recommended_idps = order_with_unavailable_last(@recommended_idps)
    @non_recommended_idps = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate_collection(suggestions[:unlikely])
    @non_recommended_idps = order_with_unavailable_last(@non_recommended_idps)
    session[:user_segments] = suggestions[:user_segments]
    FEDERATION_REPORTER.report_number_of_idps_recommended(current_transaction, request, @recommended_idps.length)
    render 'choose_a_certified_company/choose_a_certified_company_LOA2'
  end

  def select_idp
    if params[:entity_id].present?
      select_viewable_idp_for_loa(params.fetch('entity_id')) do |decorated_idp|
        session[:selected_idp_was_recommended] = recommendation_engine.recommended?(decorated_idp.identity_provider, current_identity_providers_for_loa, selected_evidence, current_transaction_simple_id)
        redirect_to warning_or_question_page(decorated_idp)
      end
    else
      render 'errors/something_went_wrong', status: 400
    end
  end

private

  def warning_or_question_page(decorated_idp)
    if not_more_than_one_uk_doc_selected && interstitial_question_flag_enabled_for(decorated_idp)
      redirect_to_idp_question_path
    else
      redirect_to_idp_warning_path
    end
  end

  def not_more_than_one_uk_doc_selected
    (%i[passport driving_licence] & selected_evidence).size <= 1
  end

  def interstitial_question_flag_enabled_for(decorated_idp)
    IDP_FEATURE_FLAGS_CHECKER.enabled?(:show_interstitial_question, decorated_idp.simple_id)
  end

  def recommendation_engine
    IDP_RECOMMENDATION_ENGINE
  end
end
