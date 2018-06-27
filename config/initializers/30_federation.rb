require 'yaml_loader'
require 'idp_recommendations/idp_profiles_loader'
require 'idp_recommendations/segment_matcher'
require 'idp_recommendations/recommendations_engine'

Rails.application.config.after_initialize do
  # Federation localisation and display
  yaml_loader = YamlLoader.new
  federation_translator = Display::FederationTranslator.new
  repository_factory = Display::RepositoryFactory.new(federation_translator, yaml_loader)
  IDP_DISPLAY_REPOSITORY = repository_factory.create_idp_repository(CONFIG.idp_display_locales)
  RP_DISPLAY_REPOSITORY = repository_factory.create_rp_repository(CONFIG.rp_display_locales)
  COUNTRY_DISPLAY_REPOSITORY = repository_factory.create_country_repository(CONFIG.country_display_locales)
  EIDAS_SCHEME_REPOSITORY = repository_factory.create_eidas_scheme_repository(CONFIG.eidas_schemes_directory)
  IDENTITY_PROVIDER_DISPLAY_DECORATOR = Display::IdentityProviderDisplayDecorator.new(
    IDP_DISPLAY_REPOSITORY,
    CONFIG.logo_directory,
    CONFIG.white_logo_directory
  )
  # HUB-135 A/B test variant
  IDENTITY_PROVIDER_DISPLAY_DECORATOR_VARIANT = Display::IdentityProviderDisplayDecoratorVariant.new(
    IDP_DISPLAY_REPOSITORY,
    CONFIG.logo_directory,
    CONFIG.white_logo_directory
  )

  EIDAS_SCHEME_DISPLAY_DECORATOR = Display::EidasSchemeDisplayDecorator.new(
    EIDAS_SCHEME_REPOSITORY,
    CONFIG.eidas_scheme_logos_directory
  )

  COUNTRY_DISPLAY_DECORATOR = Display::CountryDisplayDecorator.new(
    COUNTRY_DISPLAY_REPOSITORY,
    CONFIG.country_flags_directory
  )

  # Cycle Three display
  CYCLE_THREE_DISPLAY_REPOSITORY = repository_factory.create_cycle_three_repository(CONFIG.cycle_3_display_locales)
  CYCLE_THREE_FORMS = CycleThree::CycleThreeAttributeGenerator.new(YamlLoader.new, CYCLE_THREE_DISPLAY_REPOSITORY).attribute_classes_by_name(CONFIG.cycle_three_attributes_directory)
  FURTHER_INFORMATION_SERVICE = FurtherInformationService.new(POLICY_PROXY, CYCLE_THREE_FORMS)

  # RP/transactions config
  RP_CONFIG = YAML.load_file(CONFIG.rp_config)
  CONTINUE_ON_FAILED_REGISTRATION_RPS = RP_CONFIG.fetch('allow_continue_on_failed_registration', [])
  rps_name_and_homepage = RP_CONFIG['transaction_type']['display_name_and_homepage'] || []
  rps_name_only = RP_CONFIG['transaction_type']['display_name_only'] || []
  DATA_CORRELATOR = Display::Rp::DisplayDataCorrelator.new(federation_translator, rps_name_and_homepage.clone, rps_name_only.clone)
  TRANSACTION_TAXON_CORRELATOR = Display::Rp::TransactionTaxonCorrelator.new(federation_translator, rps_name_and_homepage.clone, rps_name_only.clone)

  # IDP Config
  IDP_CONFIG = YAML.load_file(CONFIG.idp_config)
  UNAVAILABLE_IDPS = IDP_CONFIG.fetch('show_unavailable', [])
  IDP_LOA1_ORDER = IDP_CONFIG.fetch('loa1_order', [])

  # IDP Recommendations
  idp_rules_loader = IdpProfilesLoader.new(yaml_loader)
  idp_rules = idp_rules_loader.parse_config_files(CONFIG.rules_directory)
  segment_config = YAML.load_file(CONFIG.segment_definitions)
  segment_matcher = SegmentMatcher.new(segment_config)
  transaction_grouper = TransactionGroups::TransactionGrouper.new(RP_CONFIG)
  IDP_RECOMMENDATION_ENGINE = RecommendationsEngine.new(idp_rules, segment_matcher, transaction_grouper)

  FEEDBACK_DISABLED = CONFIG.feedback_disabled

  # Feature flags
  IDP_FEATURE_FLAGS_CHECKER = IdpConfiguration::IdpFeatureFlagsLoader.new(YamlLoader.new)
                                 .load(CONFIG.rules_directory, %i[send_hints send_language_hint show_interstitial_question show_interstitial_question_loa1])
end
