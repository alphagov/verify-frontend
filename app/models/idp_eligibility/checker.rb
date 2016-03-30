module IdpEligibility
  class Checker
    def initialize(rules_repository)
      @rules_repository = rules_repository
    end

    def any_for_documents?(evidence)
      idps_at_document_stage(evidence).length > 0
    end

  private

    def docs_only
      Set.new [:passport, :driving_licence, :non_uk_id_document]
    end

    def idps_at_document_stage(evidence)
      user_docs = Set.new evidence
      matching_idps = @rules_repository.rules.select do |_, val|
        val.any? { |docs| (Set.new(docs) & docs_only).subset?(user_docs) }
      end
      matching_idps.keys
    end
  end
end
