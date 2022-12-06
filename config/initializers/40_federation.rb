require "yaml_loader"

Rails.application.config.after_initialize do
  # Federation localisation and display
  yaml_loader = YamlLoader.new
  RP_TRANSLATION_SERVICE = RpTranslationService.new
  repository_factory = Display::RepositoryFactory.new(I18n, yaml_loader)
  IDP_DISPLAY_REPOSITORY = repository_factory.create_idp_repository(CONFIG.idp_display_locales)
  RP_DISPLAY_REPOSITORY = repository_factory.create_rp_repository
  IDENTITY_PROVIDER_DISPLAY_DECORATOR = Display::IdentityProviderDisplayDecorator.new(
    IDP_DISPLAY_REPOSITORY,
    CONFIG.logo_directory,
  )

  # Cycle Three display
  CYCLE_THREE_DISPLAY_REPOSITORY = repository_factory.create_cycle_three_repository(CONFIG.cycle_3_display_locales)
  CYCLE_THREE_FORMS = CycleThree::CycleThreeAttributeGenerator.new(YamlLoader.new, CYCLE_THREE_DISPLAY_REPOSITORY).attribute_classes_by_name(CONFIG.cycle_three_attributes_directory)
  FURTHER_INFORMATION_SERVICE = FurtherInformationService.new(POLICY_PROXY, CYCLE_THREE_FORMS)

  # RP/transactions config
  RP_CONFIG = YAML.load_file(CONFIG.rp_config)
  relying_parties = RP_CONFIG["transaction_type"]["display_name_and_homepage"] || []
  DATA_CORRELATOR = Display::Rp::DisplayDataCorrelator.new(RP_DISPLAY_REPOSITORY, relying_parties.clone)
  TRANSACTION_TAXON_CORRELATOR = Display::Rp::TransactionTaxonCorrelator.new(RP_DISPLAY_REPOSITORY, relying_parties.clone)

  SERVICE_LIST_DATA_CORRELATOR = Display::Rp::ServiceListDataCorrelator.new(RP_DISPLAY_REPOSITORY)

  FEEDBACK_DISABLED = CONFIG.feedback_disabled
  THROTTLING_ENABLED = CONFIG.throttling_enabled

  # Feature flags
  SINGLE_IDP_FEATURE = CONFIG.single_idp_feature
  PUBLISH_HUB_CONFIG_ENABLED = CONFIG.publish_hub_config_enabled
  SIGN_UPS_ENABLED = CONFIG.sign_ups_enabled

  STUB_MODE = CONFIG.stub_mode
end
