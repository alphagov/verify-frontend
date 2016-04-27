class ChooseACertifiedCompanyController < ApplicationController
  protect_from_forgery except: :select_idp

  def index
    selected_evidence = IdpEligibility::EvidenceQueryStringParser.parse(request.query_string)
    evidence_query_string_value = IdpEligibility::EvidenceQueryStringBuilder.build(selected_evidence)
    @why_companies_link = uri_with_query(why_companies_path, evidence_query_string_value)

    federation_info = SESSION_PROXY.federation_info_for_session(cookies)

    grouped_identity_providers = IDP_ELIGIBILITY_CHECKER.group_by_recommendation(selected_evidence_values, federation_info.idps)

    @recommended_idps = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate_collection(grouped_identity_providers.recommended)
    @non_recommended_idps = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate_collection(grouped_identity_providers.non_recommended)
  end

  def select_idp
    selected_evidence = IdpEligibility::EvidenceQueryStringParser.parse(request.query_string)
    evidence_query_string_value = IdpEligibility::EvidenceQueryStringBuilder.build(selected_evidence)
    selected_idp = params.fetch('selected-idp')
    recommended_idp = params.fetch('recommended-idp')
    idp_choice = QueryStringBuilder.build('selected-idp' => selected_idp, 'recommended-idp' => recommended_idp)
    store_idp_selection

    redirect_to uri_with_query(redirect_to_idp_warning_path, [evidence_query_string_value, idp_choice].join('&'))
  end

  def store_idp_selection
    session[:selected_idp] = IdentityProvider.new(params['identity_provider'] || {})
    session[:selected_idp_was_recommended] = params['recommended-idp'] == 'true'
  end
end
