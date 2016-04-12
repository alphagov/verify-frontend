rules_repository = IdpEligibility::RulesRepository.new(IdpEligibility::RulesLoader.load(CONFIG.rules_directory))

DOCUMENTS_ELIGIBILITY_CHECKER = IdpEligibility::DocumentChecker.new(rules_repository)
IDP_ELIGIBILITY_CHECKER = IdpEligibility::Checker.new(rules_repository)
