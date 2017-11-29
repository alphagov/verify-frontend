require 'set'

module IdpEligibility
  class Profile
    attr_reader :rule

    def initialize(rule)
      @rule = rule.map(&:to_sym).to_set
    end

    def &(other)
      Profile.new(@rule & other)
    end

    def applies_to?(evidence)
      @rule == evidence.to_set
    end

    def ==(other)
      if is_a?(Profile)
        return @rule == other.rule
      end
      super
    end
  end
end
