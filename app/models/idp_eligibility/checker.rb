module IdpEligibility
  class Checker
    include Evidence

    GroupedIdps = Struct.new(:recommended, :non_recommended)

    def initialize(rules_repository)
      @rules_repository = rules_repository
    end

    def any?(evidence, enabled_idps)
      !filter_recommended_idps(evidence, enabled_idps).empty?
    end

    def recommended?(idp, evidence, enabled_idps)
      filter_recommended_idps(evidence, enabled_idps).include? idp
    end

    def group_by_recommendation(evidence, enabled_idps)
      recommended_idps = filter_recommended_idps(evidence, enabled_idps)
      non_recommended_idps = enabled_idps - recommended_idps
      GroupedIdps.new(recommended_idps, non_recommended_idps)
    end

  private

    def filter_recommended_idps(evidence, enabled_idps)
      recommended_idps = recommended_idps_for_profile(evidence)
      enabled_idps.select { |idp| recommended_idps.include? idp.simple_id }
    end

    def recommended_idps_for_profile(evidence)
      evidence_set = evidence.to_set
      matching_idps = @rules_repository.rules.select do |_, evidence_collection|
        evidence_collection
          .map(&:to_set)
          .any? { |evidence_rule| evidence_rule.subset?(evidence_set) }
      end
      matching_idps.keys
    end
  end
end
