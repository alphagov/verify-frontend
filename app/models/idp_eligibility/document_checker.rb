module IdpEligibility
  class DocumentChecker < DelegateClass(IdpEligibility::Checker)
    def initialize(rules_repository)
      attributes = Evidence::DOCUMENT_ATTRIBUTES
      masking_rules_repository = IdpEligibility::MaskingRulesRepository.new(rules_repository, attributes)
      super(IdpEligibility::Checker.new(masking_rules_repository))
    end
  end
end
