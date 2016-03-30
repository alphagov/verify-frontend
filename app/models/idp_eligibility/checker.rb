module IdpEligibility
  class Checker
    def initialize
      @idps = {}
    end

    def add_rule(idp, docs)
      @idps[idp] ||= []
      @idps[idp].push(Set.new docs)
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
      matching_idps = @idps.select do |_, val|
        val.any? { |docs| (docs & docs_only).subset?(user_docs) }
      end
      matching_idps.keys
    end
  end
end
