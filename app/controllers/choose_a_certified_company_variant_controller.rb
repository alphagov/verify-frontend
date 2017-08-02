class ChooseACertifiedCompanyVariantController < ApplicationController
  def index
    if is_loa1?
      loa1_idps = current_identity_providers.select { |idp| idp.levels_of_assurance.min == 'LEVEL_1' }
      @recommended_idps = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate_collection(loa1_idps)
      render :choose_a_certified_company_LOA1
    else
      grouped_identity_providers = IDP_RECOMMENDATION_GROUPER_B.group_by_recommendation(selected_evidence, current_identity_providers, current_transaction_simple_id)
      @recommended_idps = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate_collection(grouped_identity_providers.recommended)
      @non_recommended_idps = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate_collection(grouped_identity_providers.non_recommended)
      render :choose_a_certified_company_LOA2
    end
  end

  def select_idp
    selected_answer_store.store_selected_answers('interstitial', {})
    select_viewable_idp(params.fetch('entity_id')) do |decorated_idp|
      session[:selected_idp_was_recommended] = IDP_RECOMMENDATION_GROUPER_B.recommended?(decorated_idp.identity_provider, selected_evidence, current_identity_providers, current_transaction_simple_id)
      redirect_to warning_or_question_page(decorated_idp)
    end
  end

  def about
    simple_id = params[:company]
    matching_idp = current_identity_providers.detect { |idp| idp.simple_id == simple_id }
    @idp = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate(matching_idp)
    if @idp.viewable?
      @recommended = IDP_RECOMMENDATION_GROUPER_B.recommended?(@idp, selected_evidence, current_identity_providers, current_transaction_simple_id)
      render 'about'
    else
      render 'errors/404', status: 404
    end
  end

private

  def warning_or_question_page(decorated_idp)
    if only_one_uk_doc_selected && interstitial_question_flag_enabled_for(decorated_idp)
      redirect_to_idp_question_path
    else
      redirect_to_idp_warning_path
    end
  end

  def only_one_uk_doc_selected
    ([:passport, :driving_licence] & selected_evidence).size == 1
  end

  def interstitial_question_flag_enabled_for(decorated_idp)
    IDP_FEATURE_FLAGS_CHECKER.enabled?(:show_interstitial_question, decorated_idp.simple_id)
  end
end
