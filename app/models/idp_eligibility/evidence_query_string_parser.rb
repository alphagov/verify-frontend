require 'query_string_parser'

module IdpEligibility
  class EvidenceQueryStringParser
    def self.parse(query_string)
      query_params = QueryStringParser.parse(query_string)
      selected_evidence = query_params.fetch('selected-evidence', []).map do |item|
        item == 'landline_phone' ? 'landline' : item
      end
      Evidence::ALL_ATTRIBUTES.select { |evidence| selected_evidence.include? evidence.to_s }
    end
  end
end
