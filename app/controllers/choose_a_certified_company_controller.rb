class ChooseACertifiedCompanyController < ApplicationController
  def index
    grouped_identity_providers = IDP_ELIGIBILITY_CHECKER.group_by_recommendation(selected_answer_store.selected_evidence, current_identity_providers)
    @recommended_idps = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate_collection(grouped_identity_providers.recommended)
    @non_recommended_idps = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate_collection(grouped_identity_providers.non_recommended)
  end

  def select_idp
    select_viewable_idp(params.fetch('entity_id') { params.fetch('identity_provider').fetch('entity_id') }) do |decorated_idp|
      session[:selected_idp_was_recommended] =
        IDP_ELIGIBILITY_CHECKER.recommended?(decorated_idp.identity_provider, selected_answer_store.selected_evidence, current_identity_providers)
      redirect_to redirect_to_idp_warning_path
    end
  end

  def about
    simple_id = params[:company]
    matching_idp = current_identity_providers.detect { |idp| idp.simple_id == simple_id }
    @idp = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate(matching_idp)
    if @idp.viewable?
      grouped_identity_providers = IDP_ELIGIBILITY_CHECKER.group_by_recommendation(selected_answer_store.selected_evidence, [@idp])
      @recommended = grouped_identity_providers.recommended.any?
      render 'about'
    else
      render 'errors/404', status: 404
    end
  end
end
