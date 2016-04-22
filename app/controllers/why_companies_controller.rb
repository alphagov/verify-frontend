class WhyCompaniesController < ApplicationController
  def index
    selected_evidence = IdpEligibility::EvidenceQueryStringParser.parse(request.query_string)
    evidence_query_string_value = IdpEligibility::EvidenceQueryStringBuilder.build(selected_evidence)
    @choose_a_certified_company_link = uri_with_query(choose_a_certified_company_path, evidence_query_string_value)
  end
end
