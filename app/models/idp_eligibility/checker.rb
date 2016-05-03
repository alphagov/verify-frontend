require 'idp_eligibility/filter'
module IdpEligibility
  class Checker
    def initialize(rules_repository)
      @rules_repository = rules_repository
      @filter = Filter.new
    end

    def any?(evidence, enabled_idps)
      @filter.filter_idps(@rules_repository, evidence, enabled_idps).any?
    end
  end
end
