require 'set'
module IdpEligibility
  class ProfileFilter
    attr_reader :rules

    def initialize(rules)
      @rules = rules
    end

    def idps_for(evidence)
      evidence_set = evidence.to_set
      matching_profiles = @rules.select do |_simple_id, profile_collection|
        profile_collection.any? { |profile| profile.applies_to?(evidence_set) }
      end
      matching_profiles.keys
    end

    def ==(other)
      if other.is_a?(ProfileFilter)
        self.rules == other.rules
      else
        super
      end
    end
  end
end
