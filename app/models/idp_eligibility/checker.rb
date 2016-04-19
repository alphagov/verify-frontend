module IdpEligibility
  class Checker
    include Evidence

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
  end
end
