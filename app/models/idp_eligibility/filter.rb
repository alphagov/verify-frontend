module IdpEligibility
  class Filter
    def filter_idps(rules, evidence, enabled_idps)
      filtered_idps = rules.idps_for_profile(evidence)
      enabled_idps.select { |idp| filtered_idps.include?(idp.simple_id) }
    end
  end
end
