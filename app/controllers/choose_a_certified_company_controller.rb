class ChooseACertifiedCompanyController < ApplicationController
  protect_from_forgery except: :select_idp

  def index
    selected_evidence = IdpEligibility::EvidenceQueryStringParser.parse(request.query_string)
    evidence_query_string_value = IdpEligibility::EvidenceQueryStringBuilder.build(selected_evidence)
    @why_companies_link = uri_with_query(why_companies_path, evidence_query_string_value)

    federation_info = SESSION_PROXY.federation_info_for_session(cookies)

    idp_display_data = IDP_DISPLAY_DATA_CORRELATOR.correlate(federation_info.idps)

    @identity_providers = IDP_ELIGIBILITY_CHECKER.group_by_recommendation(selected_evidence, idp_display_data)
  end

  def select_idp
    selected_evidence = IdpEligibility::EvidenceQueryStringParser.parse(request.query_string)
    evidence_query_string_value = IdpEligibility::EvidenceQueryStringBuilder.build(selected_evidence)
    selected_idp = params.fetch('selected-idp')
    recommended_idp = params.fetch('recommended-idp')
    idp_choice = QueryStringBuilder.build('selected-idp' => selected_idp, 'recommended-idp' => recommended_idp)

    redirect_to uri_with_query(redirect_to_idp_warning_path, [evidence_query_string_value, idp_choice].join('&'))
  end
end
