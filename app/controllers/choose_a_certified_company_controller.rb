class ChooseACertifiedCompanyController < ApplicationController
  def index
    grouped_identity_providers = IDP_ELIGIBILITY_CHECKER.group_by_recommendation(selected_evidence_values, current_identity_providers)
    @recommended_idps = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate_collection(grouped_identity_providers.recommended)
    @non_recommended_idps = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate_collection(grouped_identity_providers.non_recommended)
  end

  def select_idp
    select_viewable_idp(params.fetch('simple_id') { params.fetch('identity_provider').fetch('simple_id') }) do |decorated_idp|
      session[:selected_idp_was_recommended] =
        IDP_ELIGIBILITY_CHECKER.recommended?(decorated_idp.identity_provider, selected_evidence_values, current_identity_providers)
      redirect_to redirect_to_idp_warning_path
    end
  end

  def about
    for_viewable_idp(params[:company]) do |decorated_idp|
      @idp = decorated_idp
      grouped_identity_providers = IDP_ELIGIBILITY_CHECKER.group_by_recommendation(selected_evidence_values, [@idp])
      @recommended = grouped_identity_providers.recommended.any?
      render 'about'
    end
  end
end
