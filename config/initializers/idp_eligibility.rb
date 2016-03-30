RULES_REPOSITORY = IdpEligibility::RulesRepository.new(IdpEligibility::RulesLoader.load(CONFIG.rules_directory))
IDP_ELIGIBILITY_CHECKER = IdpEligibility::Checker.new(RULES_REPOSITORY)
