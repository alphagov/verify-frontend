require 'yaml_loader'

Rails.application.config.after_initialize do
  # Federation localisation and display
  federation_translator = Display::FederationTranslator.new
  repository_factory = Display::RepositoryFactory.new(federation_translator)
  IDP_DISPLAY_REPOSITORY = repository_factory.create_idp_repository(CONFIG.idp_display_locales)
  RP_DISPLAY_REPOSITORY = repository_factory.create_rp_repository(CONFIG.rp_display_locales)
  COUNTRY_DISPLAY_REPOSITORY = repository_factory.create_country_repository(CONFIG.country_display_locales)
  IDENTITY_PROVIDER_DISPLAY_DECORATOR = Display::IdentityProviderDisplayDecorator.new(
    IDP_DISPLAY_REPOSITORY,
    CONFIG.logo_directory,
    CONFIG.white_logo_directory
  )
  COUNTRY_DISPLAY_DECORATOR = Display::CountryDisplayDecorator.new(
    COUNTRY_DISPLAY_REPOSITORY
  )

  # Cycle Three display
  CYCLE_THREE_DISPLAY_REPOSITORY = repository_factory.create_cycle_three_repository(CONFIG.cycle_3_display_locales)
  CYCLE_THREE_FORMS = CycleThree::CycleThreeAttributeGenerator.new(YamlLoader.new, CYCLE_THREE_DISPLAY_REPOSITORY).attribute_classes_by_name(CONFIG.cycle_three_attributes_directory)
  FURTHER_INFORMATION_SERVICE = FurtherInformationService.new(SESSION_PROXY, CYCLE_THREE_FORMS)

  # RP/transactions config
  RP_CONFIG = YAML.load_file(CONFIG.rp_config)
  CONTINUE_ON_FAILED_REGISTRATION_RPS = RP_CONFIG.fetch('allow_continue_on_failed_registration', [])
  rps_name_and_homepage = RP_CONFIG['transaction_type']['display_name_and_homepage'] || []
  rps_name_only = RP_CONFIG['transaction_type']['display_name_only'] || []
  DATA_CORRELATOR = Display::Rp::DisplayDataCorrelator.new(federation_translator, rps_name_and_homepage, rps_name_only)

  # IDP Config
  IDP_CONFIG = YAML.load_file(CONFIG.idp_config)
  UNAVAILABLE_IDPS = IDP_CONFIG.fetch('show_unavailable', [])

  # IDP Eligibility
  loaded_profile_filters = IdpEligibility::ProfilesLoader.new(YamlLoader.new).load(CONFIG.rules_directory)
  DOCUMENTS_ELIGIBILITY_CHECKER = IdpEligibility::Checker.new(loaded_profile_filters.document_profiles)
  IDP_ELIGIBILITY_CHECKER = IdpEligibility::Checker.new(loaded_profile_filters.all_profiles)
  IDP_RECOMMENDATION_GROUPER = IdpEligibility::RecommendationGrouper.new(
    loaded_profile_filters.recommended_profiles,
    loaded_profile_filters.non_recommended_profiles,
    loaded_profile_filters.demo_profiles,
    RP_CONFIG.fetch('demo_period_blacklist')
  )

  # Feature flags
  IDP_FEATURE_FLAGS_CHECKER = IdpEligibility::IdpFeatureFlagsLoader.new(YamlLoader.new)
                                 .load(CONFIG.rules_directory, [:send_hints, :send_language_hint, :show_interstitial_question])

  # IDP Eligibility B
  loaded_profile_filters_b = IdpEligibility::ProfilesLoader.new(YamlLoader.new).load(CONFIG.rules_directory_b)

  DOCUMENTS_ELIGIBILITY_CHECKER_B = IdpEligibility::Checker.new(loaded_profile_filters_b.document_profiles_b)

  IDP_ELIGIBILITY_CHECKER_B = IdpEligibility::Checker.new(loaded_profile_filters_b.recommended_profiles)

  IDP_RECOMMENDATION_GROUPER_B = IdpEligibility::RecommendationGrouper.new(
    loaded_profile_filters_b.recommended_profiles,
    loaded_profile_filters_b.non_recommended_profiles,
    loaded_profile_filters_b.demo_profiles,
    RP_CONFIG.fetch('demo_period_blacklist')
  )
end
