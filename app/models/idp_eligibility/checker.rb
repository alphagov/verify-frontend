module IdpEligibility
  class Checker
    def initialize(profile_filter)
      @profile_filter = profile_filter
    end

    def any?(evidence, enabled_idps)
      @profile_filter.filter_idps_for(evidence, enabled_idps).any?
    end
  end
end
