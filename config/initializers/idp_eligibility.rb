rules_repository = IdpEligibility::RulesLoader.new(CONFIG.rules_directory).load

DOCUMENTS_ELIGIBILITY_CHECKER = IdpEligibility::Checker.new(rules_repository.document_rules)

IDP_ELIGIBILITY_CHECKER = IdpEligibility::Checker.new(rules_repository.all_rules)

IDP_RECOMMENDATION_GROUPER = IdpEligibility::RecommendationGrouper.new(rules_repository.recommended_rules, rules_repository.non_recommended_rules)
