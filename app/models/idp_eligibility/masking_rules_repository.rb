module IdpEligibility
  class MaskingRulesRepository
    attr_reader :rules
    def initialize(repository, rule_mask)
      @rules = apply_mask(repository.rules, rule_mask)
    end

  private

    def apply_mask(unmasked_rules, rule_mask)
      unmasked_rules.inject({}) { |masked_rules, (id, rule_collection)|
        masked_rules[id] = apply_mask_to_collection(rule_collection, rule_mask)
        masked_rules
      }
    end

    def apply_mask_to_collection(collection, rule_mask)
      collection.map { |evidence_rule| evidence_rule & rule_mask }
    end
  end
end
