module IdpEligibility
  class Checker
    def initialize(rules_repository)
      @rules_repository = rules_repository
    end

    def any?(evidence, enabled_idps)
      evidence_set = evidence.to_set
      matching_idps = @rules_repository.rules.select do |_, evidence_collection|
        evidence_collection
          .map(&:to_set)
          .any? { |evidence_rule| evidence_rule.subset?(evidence_set) }
      end
      recommended_idps = matching_idps.keys
      (recommended_idps & enabled_idps).length > 0
    end

    def any_for_documents?(evidence, enabled_idps)
      recommended_idps = idps_at_document_stage(evidence)
      (recommended_idps & enabled_idps).length > 0
    end

  private

    def docs_only_mask
      [:passport, :driving_licence, :non_uk_id_document].to_set
    end

    def idps_at_document_stage(evidence)
      evidence_set = evidence.to_set
      matching_idps = @rules_repository.rules.select do |_, evidence_rule_collection|
        evidence_rule_collection
          .lazy
          .map(&:to_set)
          .map { |evidence_rule| evidence_rule & docs_only_mask }
          .any? { |evidence_rule| evidence_rule.subset?(evidence_set) }
      end
      matching_idps.keys
    end
  end
end
