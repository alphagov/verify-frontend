require 'idp_eligibility/checker'
require 'idp_eligibility/evidence'
require 'idp_eligibility/masking_rules_repository'

module IdpEligibility
  class DocumentChecker < DelegateClass(Checker)
    def initialize(rules_repository)
      attributes = Evidence::DOCUMENT_ATTRIBUTES
      masked_rules = MaskingRulesRepository.new(attributes).mask(rules_repository)
      super(IdpEligibility::Checker.new(masked_rules))
    end
  end
end
