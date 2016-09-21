loaded_profile_filters = IdpEligibility::ProfilesLoader.new(YamlLoader.new).load(CONFIG.rules_directory)

DOCUMENTS_ELIGIBILITY_CHECKER = IdpEligibility::Checker.new(loaded_profile_filters.document_profiles)

IDP_ELIGIBILITY_CHECKER = IdpEligibility::Checker.new(loaded_profile_filters.all_profiles)

IDP_RECOMMENDATION_GROUPER = IdpEligibility::RecommendationGrouper.new(
  loaded_profile_filters.recommended_profiles,
  loaded_profile_filters.non_recommended_profiles,
  loaded_profile_filters.demo_profiles,
  RP_CONFIG.fetch('demo_period_blacklist')
)
IDP_HINTS_CHECKER = IdpEligibility::IdpHintsChecker.new(loaded_profile_filters.idps_with_hints)
IDP_LANGUAGE_HINT_CHECKER = IdpEligibility::IdpHintsChecker.new(loaded_profile_filters.idps_with_language_hint)
