module IdpEligibility
  class IdpHintsChecker
    def initialize(idp_rules)
      @idp_rules = idp_rules
    end

    def enabled?(idp_simple_id)
      @idp_rules.fetch(idp_simple_id, {}).fetch(:send_hints, false)
    end
  end
end
