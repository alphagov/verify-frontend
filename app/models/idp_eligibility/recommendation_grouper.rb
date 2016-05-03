module IdpEligibility
  class RecommendationGrouper
    GroupedIdps = Struct.new(:recommended, :non_recommended)

    def initialize(recommended_rules, non_recommended_rules, filter = Filter.new)
      @recommended_rules = recommended_rules
      @non_recommended_rules = non_recommended_rules
      @filter = filter
    end

    def group_by_recommendation(evidence, enabled_idps)
      recommended_idps = @filter.filter_idps(@recommended_rules, evidence, enabled_idps)
      non_recommended_idps = @filter.filter_idps(@non_recommended_rules, evidence, enabled_idps) - recommended_idps
      GroupedIdps.new(recommended_idps, non_recommended_idps)
    end

    def recommended?(idp, evidence, enabled_idps)
      @filter.filter_idps(@recommended_rules, evidence, enabled_idps).include? idp
    end
  end
end
