module IdpConfiguration
  class IdpFeatureFlagsChecker
    def initialize(feature_flags_for_idps)
      @feature_flags_for_idps = feature_flags_for_idps
    end

    def enabled?(flag_name, idp_simple_id)
      @feature_flags_for_idps.fetch(flag_name, []).include?(idp_simple_id)
    end
  end
end
