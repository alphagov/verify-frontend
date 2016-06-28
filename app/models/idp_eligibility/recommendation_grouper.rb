module IdpEligibility
  class RecommendationGrouper
    GroupedIdps = Struct.new(:recommended, :non_recommended)

    def initialize(recommended_profile_filter, non_recommended_profile_filter, demo_profile_filter)
      @recommended_profile_filter = recommended_profile_filter
      @non_recommended_profile_filter = non_recommended_profile_filter
      @demo_profile_filter = demo_profile_filter
      @filter = Filter.new
    end

    def group_by_recommendation(evidence, enabled_idps)
      recommended_idps = recommended_idps(evidence, enabled_idps)
      non_recommended_idps = non_recommended_idps(enabled_idps, evidence) - recommended_idps
      GroupedIdps.new(recommended_idps, non_recommended_idps)
    end


    def recommended?(idp, evidence, enabled_idps)
      recommended_idps(evidence, enabled_idps).include?(idp)
    end

  private

    def non_recommended_idps(enabled_idps, evidence)
      @filter.filter_idps(@non_recommended_profile_filter, evidence, enabled_idps)
    end

    def recommended_idps(evidence, enabled_idps)
      @filter.filter_idps(@recommended_profile_filter, evidence, enabled_idps) + demo_idps(evidence, enabled_idps)
    end

    def demo_idps(evidence, enabled_idps)
      @filter.filter_idps(@demo_profile_filter, evidence, enabled_idps)
    end
  end
end
