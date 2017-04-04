# Add additional paths to load for I18n
Rails.application.config.i18n.load_path += Dir[File.join(CONFIG.rp_display_locales, '*.yml').to_s]
Rails.application.config.i18n.load_path += Dir[File.join(CONFIG.idp_display_locales, '*.yml').to_s]
Rails.application.config.i18n.load_path += Dir[File.join(CONFIG.country_display_locales, '*.yml').to_s]
Rails.application.config.i18n.load_path += Dir[File.join(CONFIG.cycle_3_display_locales, '*.yml').to_s]
