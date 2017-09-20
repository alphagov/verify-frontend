module IdpEligibility
  class RecommendationGrouper
    GroupedIdps = Struct.new(:recommended, :non_recommended)

    def initialize(recommended_profile_filter, non_recommended_profile_filter, demo_profile_filter, transaction_blacklist)
      @recommended_profile_filter = recommended_profile_filter
      @non_recommended_profile_filter = non_recommended_profile_filter
      @demo_profile_filter = demo_profile_filter
      @transaction_blacklist = transaction_blacklist
    end

    def group_by_recommendation(evidence, enabled_idps, transaction_simple_id)
      demo_profiles_should_be_recommended = demo_profiles_should_be_recommended?(transaction_simple_id)
      recommended_idps = recommended_idps(evidence, enabled_idps, demo_profiles_should_be_recommended)
      non_recommended_idps = non_recommended_idps(enabled_idps, evidence, demo_profiles_should_be_recommended) - recommended_idps
      GroupedIdps.new(recommended_idps, non_recommended_idps)
    end

    def recommended?(idp, evidence, enabled_idps, transaction_simple_id)
      recommended_idps = recommended_idps(evidence, enabled_idps, demo_profiles_should_be_recommended?(transaction_simple_id))
      recommended_idps.include?(idp)
    end

    def demo_profiles_should_be_recommended?(transaction_simple_id)
      !@transaction_blacklist.include?(transaction_simple_id)
    end

  private

    def non_recommended_idps(enabled_idps, evidence, demo_profiles_should_be_recommended)
      idps_with_non_recommended_profiles = @non_recommended_profile_filter.filter_idps_for(evidence, enabled_idps)
      if demo_profiles_should_be_recommended
        idps_with_non_recommended_profiles
      else
        idps_with_non_recommended_profiles + idps_with_demo_profiles(evidence, enabled_idps)
      end
    end

    def recommended_idps(evidence, enabled_idps, demo_profiles_should_be_recommended)
      idps_with_recommended_profiles = @recommended_profile_filter.filter_idps_for(evidence, enabled_idps)
      if demo_profiles_should_be_recommended
        idps_with_recommended_profiles + idps_with_demo_profiles(evidence, enabled_idps)
      else
        idps_with_recommended_profiles
      end
    end

    def idps_with_demo_profiles(evidence, enabled_idps)
      @demo_profile_filter.filter_idps_for(evidence, enabled_idps)
    end
  end
end
