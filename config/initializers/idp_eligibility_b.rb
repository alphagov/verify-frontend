loaded_profile_filters_b = IdpEligibility::ProfilesLoader.new(YamlLoader.new).load(CONFIG.rules_directory_b)

DOCUMENTS_ELIGIBILITY_CHECKER_B = IdpEligibility::Checker.new(loaded_profile_filters_b.document_profiles_b)

IDP_ELIGIBILITY_CHECKER_B = IdpEligibility::Checker.new(loaded_profile_filters_b.recommended_profiles)

IDP_RECOMMENDATION_GROUPER_B = IdpEligibility::RecommendationGrouper.new(
  loaded_profile_filters_b.recommended_profiles,
  loaded_profile_filters_b.non_recommended_profiles,
  loaded_profile_filters_b.demo_profiles,
  RP_CONFIG.fetch('demo_period_blacklist')
)
IDP_HINTS_CHECKER_B = IdpEligibility::IdpHintsChecker.new(loaded_profile_filters_b.idps_with_hints)
IDP_LANGUAGE_HINT_CHECKER_B = IdpEligibility::IdpHintsChecker.new(loaded_profile_filters_b.idps_with_language_hint)
