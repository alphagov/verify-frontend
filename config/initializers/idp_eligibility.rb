profiles_repository = IdpEligibility::ProfilesLoader.new(CONFIG.rules_directory).load

DOCUMENTS_ELIGIBILITY_CHECKER = IdpEligibility::Checker.new(profiles_repository.document_profiles)

IDP_ELIGIBILITY_CHECKER = IdpEligibility::Checker.new(profiles_repository.all_profiles)

IDP_RECOMMENDATION_GROUPER = IdpEligibility::RecommendationGrouper.new(profiles_repository.recommended_profiles, profiles_repository.non_recommended_profiles)
