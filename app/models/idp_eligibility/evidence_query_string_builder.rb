require 'query_string_builder'

module IdpEligibility
  class EvidenceQueryStringBuilder
    def self.build(selected_evidence)
      selected_evidence = [:no_documents] if selected_evidence.empty?
      selected_evidence = selected_evidence.map { |evidence| evidence == :landline ? :landline_phone : evidence }
      QueryStringBuilder.build('selected-evidence' => selected_evidence)
    end
  end
end
