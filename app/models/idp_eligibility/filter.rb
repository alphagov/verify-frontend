module IdpEligibility
  class Filter
    def filter_idps(rules, evidence, enabled_idps)
      filtered_idps = idps_for_profile(rules, evidence)
      enabled_idps.select { |idp| filtered_idps.include?(idp.simple_id) }
    end

  private

    def idps_for_profile(rules, evidence)
      evidence_set = evidence.to_set
      rules.select do |_, evidence_collection|
        evidence_collection
        .map(&:to_set)
        .any? { |evidence_rule| evidence_rule.subset?(evidence_set) }
      end
    end
  end
end
