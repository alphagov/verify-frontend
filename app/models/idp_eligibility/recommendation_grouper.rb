module IdpEligibility
  class RecommendationGrouper
    GroupedIdps = Struct.new(:recommended, :non_recommended)

    def initialize(recommended_profile_filter, non_recommended_profile_filter, demo_profile_filter, transaction_blacklist)
      @recommended_profile_filter = recommended_profile_filter
      @non_recommended_profile_filter = non_recommended_profile_filter
      @demo_profile_filter = demo_profile_filter
      @filter = Filter.new
      @transaction_blacklist = transaction_blacklist
    end

    def group_by_recommendation(evidence, enabled_idps, transaction_simple_id)
      allow_demos = allow_demos?(transaction_simple_id)
      recommended_idps = recommended_idps(evidence, enabled_idps, allow_demos)
      non_recommended_idps = non_recommended_idps(enabled_idps, evidence, allow_demos) - recommended_idps
      GroupedIdps.new(recommended_idps, non_recommended_idps)
    end

    def recommended?(idp, evidence, enabled_idps, transaction_simple_id)
      recommended_idps(evidence, enabled_idps, allow_demos?(transaction_simple_id)).include?(idp)
    end

    def allow_demos?(transaction_simple_id)
      !@transaction_blacklist.include?(transaction_simple_id)
    end

  private

    def non_recommended_idps(enabled_idps, evidence, allow_demos)
      idps_with_non_recommended_profiles = @filter.filter_idps(@non_recommended_profile_filter, evidence, enabled_idps)
      if allow_demos
        idps_with_non_recommended_profiles
      else
        idps_with_non_recommended_profiles + idps_with_demo_profiles(evidence, enabled_idps)
      end
    end

    def recommended_idps(evidence, enabled_idps, allow_demos)
      idps_with_recommended_profiles = @filter.filter_idps(@recommended_profile_filter, evidence, enabled_idps)
      if allow_demos
        idps_with_recommended_profiles + idps_with_demo_profiles(evidence, enabled_idps)
      else
        idps_with_recommended_profiles
      end
    end

    def idps_with_demo_profiles(evidence, enabled_idps)
      @filter.filter_idps(@demo_profile_filter, evidence, enabled_idps)
    end
  end
end
