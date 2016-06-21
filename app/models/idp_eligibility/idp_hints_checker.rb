module IdpEligibility
  class IdpHintsChecker
    def initialize(idp_rules)
      @idp_rules = idp_rules
    end

    def enabled?(idp_simple_id)
      send_hints = @idp_rules[idp_simple_id][:send_hints]
      send_hints.nil? ? false : send_hints
    end
  end
end
