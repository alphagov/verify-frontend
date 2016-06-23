module IdpEligibility
  class IdpHintsChecker
    def initialize(idps_with_hints_enabled)
      @idps_with_hints_enabled = idps_with_hints_enabled
    end

    def enabled?(idp_simple_id)
      @idps_with_hints_enabled.include?(idp_simple_id)
    end
  end
end
