module IdpEligibility
  class Checker
    def initialize(rules_repository)
      @rules_repository = rules_repository
    end

    def any?(evidence, enabled_idps)
      matching_idps = @rules_repository.rules.select do |_, evidence_collection|
        evidence_collection.any? { |evidence_items| evidence_items.to_set.subset?(evidence.to_set) }
      end
      (matching_idps.keys & enabled_idps).length > 0
    end

    def any_for_documents?(evidence, enabled_idps)
      idps = idps_at_document_stage(evidence) & enabled_idps
      idps.length > 0
    end

  private

    def docs_only
      [:passport, :driving_licence, :non_uk_id_document].to_set
    end

    def idps_at_document_stage(evidence)
      user_docs = evidence.to_set
      matching_idps = @rules_repository.rules.select do |_, evidence_collection|
        evidence_collection.any? { |evidence_items| (evidence_items.to_set & docs_only).subset?(user_docs) }
      end
      matching_idps.keys
    end
  end
end
