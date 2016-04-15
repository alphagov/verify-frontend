class ChooseACertifiedCompanyController < ApplicationController
  def index
    selected_evidence = IdpEligibility::EvidenceQueryStringParser.parse(request.query_string)
    uri = URI(why_companies_path)
    uri.query = IdpEligibility::EvidenceQueryStringBuilder.build(selected_evidence)
    @why_companies_link = uri.to_s

    federation_info = FEDERATION_INFO_GETTER.get_info(cookies)
    idps = federation_info[:idp_display_data]
    @identity_providers = IDP_ELIGIBILITY_CHECKER.group_by_recommendation(selected_evidence, idps)
  end
end
