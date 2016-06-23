require 'set'
module IdpEligibility
  class ProfileFilter
    attr_reader :idp_profiles

    def initialize(idp_profiles)
      @idp_profiles = idp_profiles
    end

    def idps_for(evidence)
      evidence_set = evidence.to_set
      matching_profiles = @idp_profiles.select do |_simple_id, profile_collection|
        profile_collection.any? { |profile| profile.applies_to?(evidence_set) }
      end
      matching_profiles.keys
    end

    def ==(other)
      if other.is_a?(ProfileFilter)
        self.idp_profiles == other.idp_profiles
      else
        super
      end
    end
  end
end
