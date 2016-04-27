class ChooseACertifiedCompanyController < ApplicationController
  protect_from_forgery except: :select_idp

  def index
    federation_info = SESSION_PROXY.federation_info_for_session(cookies)
    grouped_identity_providers = IDP_ELIGIBILITY_CHECKER.group_by_recommendation(selected_evidence_values, federation_info.idps)
    @recommended_idps = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate_collection(grouped_identity_providers.recommended)
    @non_recommended_idps = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate_collection(grouped_identity_providers.non_recommended)
  end

  def select_idp
    session[:selected_idp] = IdentityProvider.new(params.fetch('identity_provider'))
    session[:selected_idp_was_recommended] = params.fetch('recommended-idp') == 'true'
    redirect_to redirect_to_idp_warning_path
  end
end
