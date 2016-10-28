class ChooseACertifiedCompanyController < ApplicationController
  def index
    grouped_identity_providers = select_idp_recommendation.group_by_recommendation(selected_evidence, current_identity_providers, current_transaction_simple_id)
    @recommended_idps = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate_collection(grouped_identity_providers.recommended)
    @non_recommended_idps = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate_collection(grouped_identity_providers.non_recommended)
  end

  def select_idp
    select_viewable_idp(params.fetch('entity_id')) do |decorated_idp|
      session[:selected_idp_was_recommended] = select_idp_recommendation.recommended?(decorated_idp.identity_provider, selected_evidence, current_identity_providers, current_transaction_simple_id)
      redirect_to redirect_to_idp_warning_path
    end
  end

  def about
    simple_id = params[:company]
    matching_idp = current_identity_providers.detect { |idp| idp.simple_id == simple_id }
    @idp = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate(matching_idp)
    if @idp.viewable?
      @recommended = select_idp_recommendation.recommended?(@idp, selected_evidence, current_identity_providers, current_transaction_simple_id)
      render 'about'
    else
      render 'errors/404', status: 404
    end
  end

private

  def select_idp_recommendation
    ab_test_cookie = Cookies.parse_json(cookies[CookieNames::AB_TEST])['select_documents']
    alternative_name = AB_TESTS['select_documents'] ? AB_TESTS['select_documents'].alternative_name(ab_test_cookie) : 'default'
    if alternative_name == 'select_documents_new_questions_profile_change'
      return IDP_RECOMMENDATION_GROUPER_B
    else
      return IDP_RECOMMENDATION_GROUPER
    end
  end
end
