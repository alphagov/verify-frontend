require 'idp_eligibility/filter'
module IdpEligibility
  class Checker
    def initialize(profile_filter)
      @profile_filter = profile_filter
      @filter = Filter.new
    end

    def any?(evidence, enabled_idps)
      @filter.filter_idps(@profile_filter, evidence, enabled_idps).any?
    end
  end
end
