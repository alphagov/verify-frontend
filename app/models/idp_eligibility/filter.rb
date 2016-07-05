module IdpEligibility
  class Filter
    def filter_idps(profile_filter, evidence, enabled_idps)
      filtered_idps = profile_filter.idps_for(evidence)
      enabled_idps.select { |idp| filtered_idps.include?(idp.simple_id) }.to_set
    end
  end
end
