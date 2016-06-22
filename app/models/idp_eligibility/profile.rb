require 'set'

module IdpEligibility
  class Profile
    attr_reader :rule

    def initialize(rule)
      @rule = rule.map(&:to_sym).to_set
    end

    def &(rule_mask)
      Profile.new(@rule & rule_mask)
    end

    def applies_to?(evidence_set)
      @rule.subset?(evidence_set.to_set)
    end

    def ==(other)
      if is_a?(Profile)
        return @rule == other.rule
      end
      super
    end
  end
end
