loaded_profile_filters = IdpEligibility::ProfilesLoader.new(CONFIG.rules_directory).load

DOCUMENTS_ELIGIBILITY_CHECKER = IdpEligibility::Checker.new(loaded_profile_filters.document_profiles)

IDP_ELIGIBILITY_CHECKER = IdpEligibility::Checker.new(loaded_profile_filters.all_profiles)

IDP_RECOMMENDATION_GROUPER = IdpEligibility::RecommendationGrouper.new(loaded_profile_filters.recommended_profiles, loaded_profile_filters.non_recommended_profiles)
IDP_HINTS_CHECKER = IdpEligibility::IdpHintsChecker.new(TODO)
