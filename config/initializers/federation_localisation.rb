Rails.application.config.i18n.load_path += Dir[File.join(CONFIG.rp_display_locales, '*.yml').to_s]
Rails.application.config.i18n.load_path += Dir[File.join(CONFIG.idp_display_locales, '*.yml').to_s]
Rails.application.config.i18n.load_path += Dir[File.join(CONFIG.cycle_3_display_locales, '*.yml').to_s]


Rails.application.config.after_initialize do
  repository_factory = Display::RepositoryFactory.new(FEDERATION_TRANSLATOR)
  RP_DISPLAY_REPOSITORY = repository_factory.create_rp_repository(CONFIG.rp_display_locales)
  IDP_DISPLAY_REPOSITORY = repository_factory.create_idp_repository(CONFIG.idp_display_locales)
  CYCLE_THREE_DISPLAY_REPOSITORY = repository_factory.create_cycle_three_repository(CONFIG.cycle_3_display_locales)
end


Rails.application.config.after_initialize do
  CYCLE_THREE_ATTRIBUTES = CycleThree::CycleThreeAttributeGenerator.new(YamlLoader.new, CYCLE_THREE_DISPLAY_REPOSITORY)
                               .attribute_classes_by_name(CONFIG.cycle_three_attributes_directory)
  FURTHER_INFORMATION_SERVICE = FurtherInformationService.new(SESSION_PROXY, CYCLE_THREE_ATTRIBUTES)
end
