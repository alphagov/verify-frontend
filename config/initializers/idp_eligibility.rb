rules = IdpEligibility::RulesLoader.load(CONFIG.rules_directory)
rules_repository = IdpEligibility::RulesRepository.new(rules)

DOCUMENTS_ELIGIBILITY_CHECKER = IdpEligibility::DocumentChecker.new(rules_repository)
IDP_ELIGIBILITY_CHECKER = IdpEligibility::Checker.new(rules_repository)
IDP_HINTS_CHECKER = IdpEligibility::IdpHintsChecker.new(rules)
