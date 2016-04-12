module IdpEligibility
  class RulesRepository
    attr_reader :rules

    def initialize(rules_hash)
      @rules = {}
      rules_hash.each { |simple_id, rules| @rules[simple_id] = symbolize_rules(rules).to_set }
    end

  private

    def symbolize_rules(rule_list)
      rule_list.collect { |evidence| evidence.collect(&:to_sym).to_set }
    end
  end
end
